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
		// 必ず先にモデルをリリース
		m_ModelMap.clear();

		// CubismFrameworkの破棄
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
		// Cubismの設定
		m_CubismOption.LoggingLevel = Csm::CubismFramework::Option::LogLevel_Verbose;
		m_CubismOption.LogFunction = PrintMessage;

		m_CubismOption.LoadFileFunction = LoadFile;
		m_CubismOption.ReleaseBytesFunction = ReleaseBytes;

		// CubismNativeFrameworkの初期化に必要なデータを事前に渡す
		Csm::CubismFramework::StartUp(&m_CubismAllocator, &m_CubismOption);

		// CubismFrameworkの初期化
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

		if (!model->OnReceiveData(Analyser)) return false;
		
		return true;
	}
}