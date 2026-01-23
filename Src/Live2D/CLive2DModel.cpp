#include "CLive2DModel.h"
#include <LoadWorker/CFile.h>
#include <Camera/CCamera.h>
#include <Projection/CProjection.h>
#include <glm/glm.hpp>

#include <CubismModelSettingJson.hpp>

#include "Renderer/CLive2DRenderer.h"

#ifdef USE_OPENGL
#include "Renderer/OpenGL/CLive2DOpenGLRenderer.h"
#elif USE_VULKAN
#elif USE_WEBGPU
#endif

namespace livegarnet
{
	CLive2DModel::CLive2DModel():
		m_RootDirectory(std::string()),
		m_ModelSetting(nullptr),
		m_DefaultMotionGroup(std::string()),
		m_DefaultMotionIndex(-1),
		m_DefaultExpression(std::string()),
		m_Renderer(std::make_unique<CLive2DRenderer>(this))
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

		// レイアウトから初期位置を設定
		csmMap<csmString, csmFloat32> layout;
		m_ModelSetting->GetLayoutMap(layout);
		_modelMatrix->SetupFromLayout(layout);

		// 初期パラメーターを保存
		_model->SaveParameters();

		// レンダラの生成
		if (!m_Renderer->Initialize()) return false;

		// テクスチャロード
		if (!m_Renderer->LoadTextures(pGraphicsAPI, m_ModelSetting, m_RootDirectory)) return false;

		return true;
	}

	bool CLive2DModel::Update(api::IGraphicsAPI* pGraphicsAPI, float DeltaTime)
	{
		if (!_model) return true;

		// 前回のセーブデータをロード
		_model->LoadParameters();

		// 設定更新

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
		glm::mat4 ProjViewMat = Projection->GetPerspectiveMatrix() * Camera->GetViewMatrix();

		CubismMatrix44 MVPMat;
		MVPMat.SetMatrix(&ProjViewMat[0][0]);

		MVPMat.MultiplyByMatrix(_modelMatrix);

		if (!m_Renderer->Draw(MVPMat)) return false;

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