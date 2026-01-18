#pragma once

#include <memory>
#include <vector>

#include <Graphics/CTexture.h>

#include <Model/CubismUserModel.hpp>
#include <ICubismModelSetting.hpp>

using namespace Csm;

namespace api { class IGraphicsAPI; }

namespace livegarnet
{
	class CLive2DModel;

	class CLive2DRenderer
	{
	protected:
		CLive2DModel* m_Model;

		std::vector<std::shared_ptr<graphics::CTexture>> m_TextureList;

	public:
		CLive2DRenderer(CLive2DModel* model);
		virtual ~CLive2DRenderer();

		virtual bool Initialize();
		virtual bool LoadTextures(api::IGraphicsAPI* pGraphicsAPI, const std::shared_ptr<ICubismModelSetting>& ModelSetting, const std::string& Directory);

		virtual bool Draw();
	};
}