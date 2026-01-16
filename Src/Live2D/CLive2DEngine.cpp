#include "CLive2DEngine.h"
#include <Message/Console.h>

namespace livegarnet
{
	CLive2DEngine::CLive2DEngine():
		m_CubismAllocator(CLive2DMemoryAllocator())
	{
	}

	CLive2DEngine::~CLive2DEngine()
	{
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
		return true;
	}

	bool CLive2DEngine::Draw()
	{
		return true;
	}
}