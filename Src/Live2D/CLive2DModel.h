#pragma once

#include <memory>
#include <string>

#include <ICubismModelSetting.hpp>
#include <Model/CubismUserModel.hpp>

using namespace Csm;

namespace api { class IGraphicsAPI; }

namespace livegarnet
{
	class CLive2DRenderer;

	class CLive2DModel : public CubismUserModel
	{
		// ƒ‚ƒfƒ‹İ’è
		std::shared_ptr<ICubismModelSetting> m_ModelSetting;

		// ƒŒƒ“ƒ_ƒ‰[
		std::unique_ptr<CLive2DRenderer> m_Renderer;

	private:
		bool LoadMoc3(api::IGraphicsAPI* pGraphicsAPI, const std::string& Directory);
		
	public:
		CLive2DModel();
		virtual ~CLive2DModel();

		bool Load(api::IGraphicsAPI* pGraphicsAPI, const std::string& model3Path);
		bool Update();
		bool Draw();
	};
}