#include "CLive2DModel.h"
#include <LoadWorker/CFile.h>
#include <Camera/CCamera.h>
#include <Projection/CProjection.h>
#include <glm/glm.hpp>
#include <Message/Console.h>

#include <CubismModelSettingJson.hpp>
#include <Id/CubismIdManager.hpp>

#include "CLive2DSkeleton.h"
#include "Renderer/CLive2DRenderer.h"
#ifdef USE_OPENGL
#include "Renderer/OpenGL/CLive2DOpenGLRenderer.h"
#elif USE_VULKAN
#elif USE_WEBGPU
#endif
#include "Renderer/CLive2DDrawObj.h"

namespace livegarnet
{
	CLive2DModel::CLive2DModel():
		m_RootDirectory(std::string()),
		m_ModelSetting(nullptr),
		m_DefaultMotionGroup(std::string()),
		m_DefaultMotionIndex(-1),
		m_DefaultExpression(std::string()),
		m_Renderer(std::make_unique<CLive2DRenderer>(this)),
		m_Skeleton(std::make_shared<CLive2DSkeleton>()),
		m_Timecode(0)
	{
#ifdef USE_OPENGL
		m_Renderer = std::make_unique<CLive2DOpenGLRenderer>(this);
#elif USE_VULKAN
#elif USE_WEBGPU
#endif
	}

	CLive2DModel::~CLive2DModel()
	{
		Release();
	}

	void CLive2DModel::Release()
	{
		// モーションの解放
		for (auto& pair : m_MotionMap)
		{
			ACubismMotion::Delete(pair.second);
		}

		m_MotionMap.clear();

		// 表情の解放 
		for (auto& pair : m_ExpressionMap)
		{
			ACubismMotion::Delete(pair.second);
		}

		m_ExpressionMap.clear();
	}

	void CLive2DModel::SetPos(const glm::vec3& Pos)
	{
		m_Transform.SetPos(Pos);
	}

	void CLive2DModel::SetRot(const glm::quat& Rot)
	{
		m_Transform.SetRot(Rot);
	}

	void CLive2DModel::SetScale(const glm::vec3& Scale)
	{
		m_Transform.SetScale(Scale);
	}

	const std::shared_ptr<CLive2DSkeleton>& CLive2DModel::GetSkeleton() const
	{
		return m_Skeleton;
	}

	bool CLive2DModel::Load(api::IGraphicsAPI* pGraphicsAPI, const std::string& model3Path,
		const std::string& DefaultMotionGroup, int DefaultMotionIndex, const std::string& DefaultExpression)
	{
		m_DefaultMotionGroup = DefaultMotionGroup;
		m_DefaultMotionIndex = DefaultMotionIndex;

		// model3.jsonの読み込み(各機能のJSONファイルへの参照が示された設定ファイル)
		if (!LoadModel3(model3Path)) return false;
		
		// moc3(モデルの3Dデータ)
		if (!LoadMoc3(pGraphicsAPI, m_RootDirectory)) return false;

		// 物理演算
		if (!LoadPhysics(m_RootDirectory)) return false;

		// ポーズ
		// ポーズとは複数の同種パーツのうち、単一のパーツだけをモーションに基づいて切り替えをフェード表示する仕組みのこと
		// これがないと腕が４本表示されたりする
		if (!LoadPose(m_RootDirectory)) return false;

		// モーション
		if (!LoadDefaultMotionList(m_RootDirectory)) return false;

		// 表情
		if (!LoadExpressionList(m_RootDirectory)) return false;

		// ToDo: 残りの項目は後回し(まばたき、リップシンク、ユーザーデータ)

		// 初期パラメーターを保存
		_model->SaveParameters();

		// レンダラの生成
		if (!m_Renderer->Initialize()) return false;

		// スケルトン構築
		m_Skeleton->Create();

		// テクスチャロード
		if (!m_Renderer->LoadTextures(pGraphicsAPI, m_ModelSetting, m_RootDirectory)) return false;

		return true;
	}

	bool CLive2DModel::Update(api::IGraphicsAPI* pGraphicsAPI, float DeltaTime)
	{
		if (!_model) return true;

		// 前回のセーブデータをロード
		_model->LoadParameters();

		// モーション再生
		if (_motionManager->IsFinished())
		{
			// モーションが再生中でなければデフォルトモーションを再生開始する
			if (!ChangeMotion(m_DefaultMotionGroup, m_DefaultMotionIndex)) return false;
		}
		else
		{
			// 再生中なのでモーションを更新する
			_motionManager->UpdateMotion(_model, DeltaTime);
		}

		// 表情を再生
		if (_expressionManager->IsFinished())
		{
			// 表情が再生中でなければデフォルトの表情を再生開始する
			if (!ChangeExpression(m_DefaultExpression)) return false;
		}
		else
		{
			// 再生中なので表情を更新する
			_expressionManager->UpdateMotion(_model, DeltaTime);
		}

		// スケルトン更新
		if (!m_Skeleton->Update(_model)) return false;

		// ポーズの設定
		if (_pose)
		{
			_pose->UpdateParameters(_model, DeltaTime);
		}

		// 物理演算
		if (_physics)
		{
			_physics->Evaluate(_model, DeltaTime);
		}

		// 更新内容をセーブ
		_model->SaveParameters();

		// モデルの頂点情報を更新
		_model->Update();

		return true;
	}

	bool CLive2DModel::Draw(api::IGraphicsAPI* pGraphicsAPI, const std::shared_ptr<camera::CCamera>& Camera,
		const std::shared_ptr<projection::CProjection>& Projection, const std::shared_ptr<graphics::CDrawInfo>& DrawInfo)
	{
		if (!_model) return true;

		// MVP行列の計算
		glm::mat4 MVPMat_glm = Projection->GetPerspectiveMatrix() * Camera->GetViewMatrix() * m_Transform.GetModelMatrix();

		CubismMatrix44 MVPMat;
		MVPMat.SetMatrix(&MVPMat_glm[0][0]);

#ifdef USE_DRAW_SORT
		float ToCameraDist = glm::distance(m_Transform.GetPos(), Camera->GetPos());

		std::shared_ptr<CLive2DDrawObj> DrawObj = std::make_shared<CLive2DDrawObj>(2000, ToCameraDist, MVPMat, m_Renderer.get());

		if (!pGraphicsAPI->AddDrawObj(DrawObj)) return false;
#else
		if (!m_Renderer->Draw(MVPMat)) return false;
#endif // USE_DRAW_SORT

		return true;
	}

	bool CLive2DModel::ChangeMotion(const std::string& MotionGroup, int Index)
	{
		std::string key = CreateMotionKey(MotionGroup, Index);

		ACubismMotion* pMotion = nullptr;
		bool autoDelete = false;

		const auto& it = m_MotionMap.find(key);
		if (it == m_MotionMap.end())
		{
			// 未登録モーションなので新規ロードして再生
			std::string fileName = m_ModelSetting->GetMotionFileName(MotionGroup.c_str(), Index);
			if (fileName.empty()) return true;

			std::string fullPath = m_RootDirectory + fileName;

			resource::CFile File = resource::CFile(fullPath);
			if (!File.LoadImmediate()) return false;

			const auto& data = File.GetData();

			CubismMotion* pMotion = CubismMotion::Create(&data[0], data.size());
			if (!pMotion) return false;

			// 未登録モーションはその場限りの使用で再生が終わったらメモリを削除する
			autoDelete = true;
		}
		else
		{
			// 登録済みモーションである
			pMotion = it->second;
		}

		if (!pMotion) return false;

		_motionManager->StartMotion(pMotion, autoDelete);

		return true;
	}

	bool CLive2DModel::ChangeExpression(const std::string& ExpressionName)
	{
		const auto& it = m_ExpressionMap.find(ExpressionName);
		if (it == m_ExpressionMap.end()) return true;

		ACubismMotion* pMotion = it->second;
		if (!pMotion) return false;

		_expressionManager->StartMotion(pMotion, false);

		return true;
	}

	bool CLive2DModel::OnReceiveData(binary::CBinaryReader& Analyser)
	{
		if (!m_Skeleton) return true;

		int version = 0;
		if (!Analyser.GetInt(version)) return false;

		int firstFlag = 0;
		if (!Analyser.GetInt(firstFlag)) return false;

		// 最初のデータならタイムコードをリセット
		bool firstMsg = (firstFlag == 1);
		if (firstMsg)
		{
			m_Timecode = 0;
		}

		// タイムコード
		int ReceivedTimecode = 0;
		if (!Analyser.GetInt(ReceivedTimecode)) return false;

		// 古いデータが来たら捨てる
		if (ReceivedTimecode < m_Timecode) return true;

		// 新しいデータなのでタイムコードを更新する
		m_Timecode = ReceivedTimecode;

		float Rate = 1.0f;

		// Head
		{
			glm::quat Quat;
			if (!Analyser.GetFloat(Quat.x)) return false;
			if (!Analyser.GetFloat(Quat.y)) return false;
			if (!Analyser.GetFloat(Quat.z)) return false;
			if (!Analyser.GetFloat(Quat.w)) return false;

			glm::vec3 Euler = glm::eulerAngles(Quat);
			Euler.x = glm::degrees(Euler.x);
			Euler.y = glm::degrees(Euler.y);
			Euler.z = glm::degrees(Euler.z);

			// X軸補正
			{
				// X軸回転は正面が30度ぐらいなので0度になるように補正する 
				Euler.x -= 30.0f;

				// 上下逆にしてちょっと誇張する
				Euler.x *= -1.0f;
				Euler.x *= 10.0f;
			}

			// Y軸補正
			{
				// 左右逆にしてちょっと誇張する
				Euler.y *= -1.0f;
				Euler.y *= 3.0f;
			}

			/*// Z軸補正
			{
				// ちょっと誇張する
				Euler.z *= -1.0f;
				Euler.z *= 10.0f;
			}*/

			m_Skeleton->SetCommonBoneValue("ParamAngleX", Euler.y, Rate);
			m_Skeleton->SetCommonBoneValue("ParamAngleY", Euler.x, Rate);
			//m_Skeleton->SetCommonBoneValue("ParamAngleZ", Euler.z, Rate);

			//Console::Log("HeadEuler => x: %f, y: %f, z: %f\n", Euler.x, Euler.y, Euler.z);
		}

		// Body
		{
			glm::quat Quat;
			if (!Analyser.GetFloat(Quat.x)) return false;
			if (!Analyser.GetFloat(Quat.y)) return false;
			if (!Analyser.GetFloat(Quat.z)) return false;
			if (!Analyser.GetFloat(Quat.w)) return false;

			glm::vec3 Euler = glm::eulerAngles(Quat);
			Euler.x = glm::degrees(Euler.x);
			Euler.y = glm::degrees(Euler.y);
			Euler.z = glm::degrees(Euler.z);

			/*// X軸補正
			{
				// X軸回転は正面が65度ぐらいなので0度になるように補正する 
				Euler.x -= 65.0f;

				// 上下逆にしてちょっと誇張する
				Euler.x *= -1.0f;
				Euler.x *= 20.0f;
			}*/

			// Y軸補正
			{
				// 左右逆にしてちょっと誇張する
				Euler.y *= -1.0f;
				Euler.y *= 3.0f;
			}

			/*// Z軸補正
			{
				// ちょっと誇張する
				Euler.z *= 20.0f;
			}*/

			m_Skeleton->SetCommonBoneValue("ParamBodyAngleX", Euler.y, Rate);
			m_Skeleton->SetCommonBoneValue("ParamBodyAngleY", Euler.x, Rate);
			//m_Skeleton->SetCommonBoneValue("ParamBodyAngleZ", Euler.z, Rate);

			//Console::Log("BodyEuler => x: %f, y: %f, z: %f\n", Euler.x, Euler.y, Euler.z);
		}

		// 左腕
		{
			glm::quat Quat;
			if (!Analyser.GetFloat(Quat.x)) return false;
			if (!Analyser.GetFloat(Quat.y)) return false;
			if (!Analyser.GetFloat(Quat.z)) return false;
			if (!Analyser.GetFloat(Quat.w)) return false;

			glm::vec3 Euler = glm::eulerAngles(Quat);
			Euler.x = glm::degrees(Euler.x);
			Euler.y = glm::degrees(Euler.y);
			Euler.z = glm::degrees(Euler.z);
		}

		// 右腕
		{
			glm::quat Quat;
			if (!Analyser.GetFloat(Quat.x)) return false;
			if (!Analyser.GetFloat(Quat.y)) return false;
			if (!Analyser.GetFloat(Quat.z)) return false;
			if (!Analyser.GetFloat(Quat.w)) return false;

			glm::vec3 Euler = glm::eulerAngles(Quat);
			Euler.x = glm::degrees(Euler.x);
			Euler.y = glm::degrees(Euler.y);
			Euler.z = glm::degrees(Euler.z);
		}

		// 左手
		{
			glm::quat Quat;
			if (!Analyser.GetFloat(Quat.x)) return false;
			if (!Analyser.GetFloat(Quat.y)) return false;
			if (!Analyser.GetFloat(Quat.z)) return false;
			if (!Analyser.GetFloat(Quat.w)) return false;

			glm::vec3 Euler = glm::eulerAngles(Quat);
			Euler.x = glm::degrees(Euler.x);
			Euler.y = glm::degrees(Euler.y);
			Euler.z = glm::degrees(Euler.z);
		}

		// 右手
		{
			glm::quat Quat;
			if (!Analyser.GetFloat(Quat.x)) return false;
			if (!Analyser.GetFloat(Quat.y)) return false;
			if (!Analyser.GetFloat(Quat.z)) return false;
			if (!Analyser.GetFloat(Quat.w)) return false;

			glm::vec3 Euler = glm::eulerAngles(Quat);
			Euler.x = glm::degrees(Euler.x);
			Euler.y = glm::degrees(Euler.y);
			Euler.z = glm::degrees(Euler.z);
		}

		return true;
	}

	std::string CLive2DModel::CreateMotionKey(const std::string& MotionGroup, int Index) const
	{
		std::string key = std::string(MotionGroup) + "_" + std::to_string(Index);

		return key;
	}

	bool CLive2DModel::LoadModel3(const std::string& model3Path)
	{
		resource::CFile File = resource::CFile(model3Path);
		if (!File.LoadImmediate()) return false;

		const auto& data = File.GetData();
		m_ModelSetting = std::make_shared<CubismModelSettingJson>(&data[0], data.size());

		// ルートディレクトリの設定
		m_RootDirectory = File.GetDirectory();

		return true;
	}

	bool CLive2DModel::LoadMoc3(api::IGraphicsAPI* pGraphicsAPI, const std::string& Directory)
	{
		if (!m_ModelSetting) return false;

		// moc3ファイルの読み込み
		std::string moc3Path = Directory + m_ModelSetting->GetModelFileName();

		resource::CFile File = resource::CFile(moc3Path);
		if (!File.LoadImmediate()) return false;

		const auto& data = File.GetData();

		LoadModel(&data[0], data.size());

		return true;
	}

	bool CLive2DModel::LoadPhysics(const std::string& Directory)
	{
		if (!m_ModelSetting) return false;

		std::string fileName = m_ModelSetting->GetPhysicsFileName();
		if (fileName.empty()) return true;

		std::string fullPath = Directory + fileName;

		resource::CFile File = resource::CFile(fullPath);
		if (!File.LoadImmediate()) return false;

		const auto& data = File.GetData();

		_physics = CubismPhysics::Create(&data[0], data.size());

		return true;
	}

	bool CLive2DModel::LoadPose(const std::string& Directory)
	{
		if (!m_ModelSetting) return false;

		std::string fileName = m_ModelSetting->GetPoseFileName();
		if (fileName.empty()) return true;

		std::string fullPath = Directory + fileName;

		resource::CFile File = resource::CFile(fullPath);
		if (!File.LoadImmediate()) return false;

		const auto& data = File.GetData();

		_pose = CubismPose::Create(&data[0], data.size());

		return true;
	}

	bool CLive2DModel::LoadDefaultMotionList(const std::string& Directory)
	{
		if (!m_ModelSetting) return false;

		for (int GroupIndex = 0; GroupIndex < m_ModelSetting->GetMotionGroupCount(); GroupIndex++)
		{
			const auto& MotionGroupName = m_ModelSetting->GetMotionGroupName(GroupIndex);

			for (int MotionIndex = 0; MotionIndex < m_ModelSetting->GetMotionCount(MotionGroupName); MotionIndex++)
			{
				std::string fileName = m_ModelSetting->GetMotionFileName(MotionGroupName, MotionIndex);
				if (fileName.empty()) continue;

				std::string fullPath = Directory + fileName;

				resource::CFile File = resource::CFile(fullPath);
				if (!File.LoadImmediate()) return false;

				const auto& data = File.GetData();

				CubismMotion* pMotion = CubismMotion::Create(&data[0], data.size());

				if (pMotion)
				{
					std::string key = CreateMotionKey(MotionGroupName, MotionIndex);

					m_MotionMap.emplace(key, pMotion);
				}
			}
		}

		return true;
	}

	bool CLive2DModel::LoadExpressionList(const std::string& Directory)
	{
		if (!m_ModelSetting) return false;

		for (int i = 0; i < m_ModelSetting->GetExpressionCount(); i++)
		{
			std::string fileName = m_ModelSetting->GetExpressionFileName(i);
			if (fileName.empty()) continue;

			std::string path = Directory + fileName;

			resource::CFile File = resource::CFile(path);
			if (!File.LoadImmediate()) return false;

			const auto& data = File.GetData();

			auto ExpressionName = m_ModelSetting->GetExpressionName(i);
			ACubismMotion* motion = LoadExpression(&data[0], data.size(), ExpressionName);

			if (motion)
			{
				m_ExpressionMap.emplace(ExpressionName, motion);
			}
		}

		return true;
	}
}