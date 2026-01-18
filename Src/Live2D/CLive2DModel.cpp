#include "CLive2DModel.h"
#include <LoadWorker/CFile.h>

#include <CubismModelSettingJson.hpp>

#include "Renderer/CLive2DRenderer.h"

#ifdef USE_OPENGL
#include "Renderer/OpenGL/CLive2DOpenGLRenderer.h"
#elif USE_VULKAN
#elif USE_WEBGPU
#endif

namespace livegarnet
{
	CLive2DModel::CLive2DModel():
		m_ModelSetting(nullptr),
		m_Renderer(std::make_unique<CLive2DRenderer>(this))
	{
#ifdef USE_OPENGL
		m_Renderer = std::make_unique<CLive2DOpenGLRenderer>(this);
#elif USE_VULKAN
#elif USE_WEBGPU
#endif
	}

	CLive2DModel::~CLive2DModel()
	{
	}

	bool CLive2DModel::Load(api::IGraphicsAPI* pGraphicsAPI, const std::string& model3Path)
	{
		// model3.jsonの読み込み
		resource::CFile File = resource::CFile(model3Path);
		if (!File.LoadImmediate()) return false;

		const auto& data = File.GetData();
		m_ModelSetting = std::make_shared<CubismModelSettingJson>(&data[0], data.size());

		// moc3
		if (!LoadMoc3(pGraphicsAPI, File.GetDirectory())) return false;

		// レイアウトから初期位置を設定
		csmMap<csmString, csmFloat32> layout;
		m_ModelSetting->GetLayoutMap(layout);
		_modelMatrix->SetupFromLayout(layout);

		// 初期パラメーターを保存
		_model->SaveParameters();

		// レンダラの生成
		if (!m_Renderer->Initialize()) return false;

		// テクスチャロード
		if (!m_Renderer->LoadTextures(pGraphicsAPI, m_ModelSetting, File.GetDirectory())) return false;

		return true;
	}

	bool CLive2DModel::Update()
	{
		// モデルの頂点情報を更新
		_model->Update();

		return true;
	}

	bool CLive2DModel::Draw()
	{
		if (!m_Renderer->Draw()) return false;

		return true;
	}

	bool CLive2DModel::LoadMoc3(api::IGraphicsAPI* pGraphicsAPI, const std::string& Directory)
	{
		if (!m_ModelSetting) return false;

		// moc3ファイルの読み込み
		std::string moc3Path = Directory + m_ModelSetting->GetModelFileName();

		resource::CFile File = resource::CFile(moc3Path);
		if (!File.LoadImmediate()) return false;

		const auto& data = File.GetData();

		LoadModel(&data[0], data.size());

		return true;
	}
}