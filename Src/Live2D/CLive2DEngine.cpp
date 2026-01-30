#include "CLive2DEngine.h"
#include <Message/Console.h>
#include <LoadWorker/CFile.h>
#include "CLive2DModel.h"
#include "CLive2DSkeleton.h"

namespace livegarnet
{
	CLive2DEngine::CLive2DEngine():
		m_CubismOption(),
		m_CubismAllocator(CLive2DMemoryAllocator())
	{
	}

	CLive2DEngine::~CLive2DEngine()
	{
		// ïKÇ∏êÊÇ…ÉÇÉfÉãÇÉäÉäÅ[ÉX
		m_ModelMap.clear();

		// CubismFrameworkÇÃîjä¸
		Csm::CubismFramework::Dispose();
	}

	void CLive2DEngine::PrintMessage(const Csm::csmChar* message)
	{
		Console::Log("[Live2D] message: %s\n", message);
	}

	csmByte* CLive2DEngine::LoadFile(const std::string filePath, csmSizeInt* outSize)
	{
		std::string SrcPath = "Resources/User/Live2D/Shader/OpenGL/" + filePath;

		resource::CFile File = resource::CFile(SrcPath);
		if (!File.LoadImmediate()) return NULL;

		const auto& data = File.GetData();

		void* Dst = malloc(data.size());

		std::memcpy(Dst, &data[0], data.size());
		*outSize = data.size();

		return (csmByte*)Dst;
	}

	void CLive2DEngine::ReleaseBytes(Csm::csmByte* byteData)
	{
		free(byteData);
	}

	bool CLive2DEngine::Initialize()
	{
		// CubismÇÃê›íË
		m_CubismOption.LoggingLevel = Csm::CubismFramework::Option::LogLevel_Verbose;
		m_CubismOption.LogFunction = PrintMessage;

		m_CubismOption.LoadFileFunction = LoadFile;
		m_CubismOption.ReleaseBytesFunction = ReleaseBytes;

		// CubismNativeFrameworkÇÃèâä˙âªÇ…ïKóvÇ»ÉfÅ[É^ÇéñëOÇ…ìnÇ∑
		Csm::CubismFramework::StartUp(&m_CubismAllocator, &m_CubismOption);

		// CubismFrameworkÇÃèâä˙âª
		Csm::CubismFramework::Initialize();

		return true;
	}

	bool CLive2DEngine::Update(api::IGraphicsAPI* pGraphicsAPI, float DeltaTime)
	{
		for (auto& Model : m_ModelMap)
		{
			if (!Model.second->Update(pGraphicsAPI, DeltaTime)) return false;
		}

		return true;
	}

	bool CLive2DEngine::Draw(api::IGraphicsAPI* pGraphicsAPI, const std::shared_ptr<camera::CCamera>& Camera,
		const std::shared_ptr<projection::CProjection>& Projection, const std::shared_ptr<graphics::CDrawInfo>& DrawInfo)
	{
		for (auto& Model : m_ModelMap)
		{
			if (!Model.second->Draw(pGraphicsAPI, Camera, Projection, DrawInfo)) return false;
		}

		return true;
	}

	bool CLive2DEngine::LoadModel(api::IGraphicsAPI* pGraphicsAPI, const std::string& name, const std::string& model3Path,
		const std::string& DefaultMotionGroup, int DefaultMotionIndex, const std::string& DefaultExpression)
	{
		std::shared_ptr<CLive2DModel> model = std::make_shared<CLive2DModel>();
		if (!model->Load(pGraphicsAPI, model3Path, DefaultMotionGroup, DefaultMotionIndex, DefaultExpression)) return false;

		m_ModelMap.emplace(name, model);

		return true;
	}

	bool CLive2DEngine::ChangeMotion(const std::string& ModelName, const std::string& MotionGroup, int Index)
	{
		const auto& it = m_ModelMap.find(ModelName);
		if (it == m_ModelMap.end()) return true;

		const auto& model = it->second;
		if (!model->ChangeMotion(MotionGroup, Index)) return false;

		return true;
	}

	bool CLive2DEngine::ChangeExpression(const std::string& ModelName, const std::string& ExpressionName)
	{
		const auto& it = m_ModelMap.find(ModelName);
		if (it == m_ModelMap.end()) return true;

		const auto& model = it->second;
		if (!model->ChangeExpression(ExpressionName)) return false;

		return true;
	}

	bool CLive2DEngine::OnReceiveData(const std::string& ModelName, binary::CBinaryReader& Analyser)
	{
		const auto& it = m_ModelMap.find(ModelName);
		if (it == m_ModelMap.end()) return true;

		const auto& model = it->second;
		if (!model) return true;

		const auto& skeleton = model->GetSkeleton();
		if (!skeleton) return true;

		int version = 0;
		if (!Analyser.GetInt(version)) return false;

		float Rate = 0.1f;

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

			// Xé≤ï‚ê≥
			{
				// Xé≤âÒì]ÇÕê≥ñ Ç™30ìxÇÆÇÁÇ¢Ç»ÇÃÇ≈0ìxÇ…Ç»ÇÈÇÊÇ§Ç…ï‚ê≥Ç∑ÇÈ 
				Euler.x -= 30.0f;

				// è„â∫ãtÇ…ÇµÇƒÇøÇÂÇ¡Ç∆å÷í£Ç∑ÇÈ
				Euler.x *= -1.0f;
				Euler.x *= 20.0f;
			}

			// Yé≤ï‚ê≥
			{
				// ç∂âEãtÇ…ÇµÇƒÇøÇÂÇ¡Ç∆å÷í£Ç∑ÇÈ
				Euler.y *= -1.0f;
				Euler.y *= 20.0f;
			}

			// Zé≤ï‚ê≥
			{
				// ÇøÇÂÇ¡Ç∆å÷í£Ç∑ÇÈ
				Euler.z *= 20.0f;
			}

			skeleton->SetCommonBoneValue("ParamAngleX", Euler.y, Rate);
			skeleton->SetCommonBoneValue("ParamAngleY", Euler.x, Rate);
			skeleton->SetCommonBoneValue("ParamAngleZ", Euler.z, Rate);

			Console::Log("HeadEuler => x: %f, y: %f, z: %f\n", Euler.x, Euler.y, Euler.z);
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

			// Xé≤ï‚ê≥
			{
				// Xé≤âÒì]ÇÕê≥ñ Ç™65ìxÇÆÇÁÇ¢Ç»ÇÃÇ≈0ìxÇ…Ç»ÇÈÇÊÇ§Ç…ï‚ê≥Ç∑ÇÈ 
				Euler.x -= 65.0f;

				// è„â∫ãtÇ…ÇµÇƒÇøÇÂÇ¡Ç∆å÷í£Ç∑ÇÈ
				Euler.x *= -1.0f;
				Euler.x *= 20.0f;
			}

			// Yé≤ï‚ê≥
			{
				// ç∂âEãtÇ…ÇµÇƒÇøÇÂÇ¡Ç∆å÷í£Ç∑ÇÈ
				Euler.y *= -1.0f;
				Euler.y *= 20.0f;
			}

			// Zé≤ï‚ê≥
			{
				// ÇøÇÂÇ¡Ç∆å÷í£Ç∑ÇÈ
				Euler.z *= 20.0f;
			}

			skeleton->SetCommonBoneValue("ParamBodyAngleX", Euler.y, Rate);
			skeleton->SetCommonBoneValue("ParamBodyAngleY", Euler.x, Rate);
			skeleton->SetCommonBoneValue("ParamBodyAngleZ", Euler.z, Rate);

			Console::Log("BodyEuler => x: %f, y: %f, z: %f\n", Euler.x, Euler.y, Euler.z);
		}
		
		// ç∂òr
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

		// âEòr
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

		// ç∂éË
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

		// âEéË
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
}