#pragma once

#include <CubismFramework.hpp>

#include <memory>
#include <map>
#include "CLive2DMemoryAllocator.h"

namespace livegarnet
{
	class CLive2DModel;

	class CLive2DEngine
	{
		// オプション設定
		Csm::CubismFramework::Option m_CubismOption;

		// メモリアロケーター
		CLive2DMemoryAllocator m_CubismAllocator;

		// モデルリスト
		std::map<std::string, std::shared_ptr<CLive2DModel>> m_ModelMap;

	private:
		static void PrintMessage(const Csm::csmChar* message);

	public:
		CLive2DEngine();
		virtual ~CLive2DEngine();

		bool Initialize();
		bool Update();
		bool Draw();

		// 各モデル関係
		bool LoadModel(const std::string& name, const std::string& model3Path);
	};
}