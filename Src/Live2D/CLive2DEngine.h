#pragma once

#include <CubismFramework.hpp>

#include <memory>
#include <map>
#include "CLive2DMemoryAllocator.h"

using namespace Csm;

namespace api { class IGraphicsAPI; }
namespace camera { class CCamera; }
namespace projection { class CProjection; }
namespace graphics { class CDrawInfo; }

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
		static csmByte* LoadFile(const std::string filePath, csmSizeInt* outSize);
		static void ReleaseBytes(Csm::csmByte* byteData);

	public:
		CLive2DEngine();
		virtual ~CLive2DEngine();

		bool Initialize();
		bool Update(api::IGraphicsAPI* pGraphicsAPI, float DeltaTime);
		bool Draw(api::IGraphicsAPI* pGraphicsAPI, const std::shared_ptr<camera::CCamera>& Camera, 
			const std::shared_ptr<projection::CProjection>& Projection, const std::shared_ptr<graphics::CDrawInfo>& DrawInfo);

		// 各モデル関係
		bool LoadModel(api::IGraphicsAPI* pGraphicsAPI, const std::string& name, const std::string& model3Path,
			const std::string& DefaultMotionGroup, int DefaultMotionIndex, const std::string& DefaultExpression);

		bool ChangeMotion(const std::string& ModelName, const std::string& MotionGroup, int Index);
		bool ChangeExpression(const std::string& ModelName, const std::string& ExpressionName);
	};
}