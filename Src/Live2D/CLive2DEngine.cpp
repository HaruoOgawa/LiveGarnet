#include "CLive2DEngine.h"
#include <Message/Console.h>
#include "CLive2DModel.h"

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

	bool CLive2DEngine::Initialize()
	{
		// Cubismの設定
		m_CubismOption.LoggingLevel = Csm::CubismFramework::Option::LogLevel_Verbose;
		m_CubismOption.LogFunction = PrintMessage;

		// CubismNativeFrameworkの初期化に必要なデータを事前に渡す
		Csm::CubismFramework::StartUp(&m_CubismAllocator, &m_CubismOption);

		// CubismFrameworkの初期化
		Csm::CubismFramework::Initialize();

		return true;
	}

	bool CLive2DEngine::Update()
	{
		for (auto& Model : m_ModelMap)
		{
			if (!Model.second->Update()) return false;
		}

		return true;
	}

	bool CLive2DEngine::Draw()
	{
		for (auto& Model : m_ModelMap)
		{
			if (!Model.second->Draw()) return false;
		}

		return true;
	}

	bool CLive2DEngine::LoadModel(api::IGraphicsAPI* pGraphicsAPI, const std::string& name, const std::string& model3Path)
	{
		std::shared_ptr<CLive2DModel> model = std::make_shared<CLive2DModel>();
		if (!model->Load(pGraphicsAPI, model3Path)) return false;

		m_ModelMap.emplace(name, model);

		return true;
	}
}