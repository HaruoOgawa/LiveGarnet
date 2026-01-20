#pragma once

#include <memory>
#include <string>

#include <ICubismModelSetting.hpp>
#include <Model/CubismUserModel.hpp>

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
		// ÉÇÉfÉãê›íË
		std::shared_ptr<ICubismModelSetting> m_ModelSetting;

		// ÉåÉìÉ_ÉâÅ[
		std::unique_ptr<CLive2DRenderer> m_Renderer;

	private:
		bool LoadMoc3(api::IGraphicsAPI* pGraphicsAPI, const std::string& Directory);
		
	public:
		CLive2DModel();
		virtual ~CLive2DModel();

		bool Load(api::IGraphicsAPI* pGraphicsAPI, const std::string& model3Path);
		bool Update();
		bool Draw(api::IGraphicsAPI* pGraphicsAPI, const std::shared_ptr<camera::CCamera>& Camera,
			const std::shared_ptr<projection::CProjection>& Projection, const std::shared_ptr<graphics::CDrawInfo>& DrawInfo);
	};
}