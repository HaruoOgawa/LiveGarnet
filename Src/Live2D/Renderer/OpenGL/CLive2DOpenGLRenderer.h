#ifdef USE_OPENGL
#pragma once

#include <Interface/IGraphicsAPI.h>

#include "../CLive2DRenderer.h"

namespace livegarnet
{
	class CLive2DModel;

	class CLive2DOpenGLRenderer : public CLive2DRenderer
	{
	public:
		CLive2DOpenGLRenderer(CLive2DModel* model);
		virtual ~CLive2DOpenGLRenderer();

		virtual bool Initialize() override;

		virtual bool LoadTextures(api::IGraphicsAPI* pGraphicsAPI, const std::shared_ptr<ICubismModelSetting>& ModelSetting, const std::string& Directory) override;

		virtual bool Draw() override;
	};
}
#endif USE_OPENGL