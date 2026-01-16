#pragma once

#include <CubismFramework.hpp>
#include "CLive2DMemoryAllocator.h"

namespace livegarnet
{
	class CLive2DEngine
	{
		// オプション設定
		Csm::CubismFramework::Option m_CubismOption;

		// メモリアロケーター
		CLive2DMemoryAllocator m_CubismAllocator;

	private:
		static void PrintMessage(const Csm::csmChar* message);

	public:
		CLive2DEngine();
		virtual ~CLive2DEngine();

		bool Initialize();
		bool Update();
		bool Draw();
	};
}