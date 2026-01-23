#pragma once

#include <memory>
#include <string>
#include <map>

#include <ICubismModelSetting.hpp>
#include <Model/CubismUserModel.hpp>
#include <Motion/CubismMotionManager.hpp>
#include <Motion/CubismMotion.hpp>

using namespace Csm;

namespace api { class IGraphicsAPI; }
namespace camera { class CCamera; }
namespace projection { class CProjection; }
namespace graphics { class CDrawInfo; }

namespace livegarnet
{
	class CLive2DRenderer;

	class CLive2DModel : public CubismUserModel
	{
		std::string m_RootDirectory;

		// モデル設定
		std::shared_ptr<ICubismModelSetting> m_ModelSetting;

		// モーション
		std::string m_DefaultMotionGroup;
		int m_DefaultMotionIndex;
		
		std::unique_ptr<CubismMotionManager> m_MotionManager;
		std::map<std::string, ACubismMotion*> m_MotionMap;

		// 表情
		std::string m_DefaultExpression;

		std::unique_ptr<CubismMotionManager> m_ExpressionManager;
		std::map<std::string, ACubismMotion*> m_ExpressionMap;

		// レンダラー
		std::unique_ptr<CLive2DRenderer> m_Renderer;

	private:
		void Release();

		bool LoadMoc3(api::IGraphicsAPI* pGraphicsAPI, const std::string& Directory);
		bool LoadExpressionList(const std::string& Directory);
		bool LoadDefaultMotionList(const std::string& Directory);

		std::string CreateMotionKey(const std::string& MotionGroup, int Index) const;
	public:
		CLive2DModel();
		virtual ~CLive2DModel();

		bool Load(api::IGraphicsAPI* pGraphicsAPI, const std::string& model3Path, 
			const std::string& DefaultMotionGroup, int DefaultMotionIndex, const std::string& DefaultExpression);

		bool Update(api::IGraphicsAPI* pGraphicsAPI, float DeltaTime);
		
		bool Draw(api::IGraphicsAPI* pGraphicsAPI, const std::shared_ptr<camera::CCamera>& Camera,
			const std::shared_ptr<projection::CProjection>& Projection, const std::shared_ptr<graphics::CDrawInfo>& DrawInfo);

		bool ChangeMotion(const std::string& MotionGroup, int Index);
		bool ChangeExpression(const std::string& ExpressionName);
	};
}