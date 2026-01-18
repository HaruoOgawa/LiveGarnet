#include "CLive2DModel.h"
#include <LoadWorker/CFile.h>

#include <CubismModelSettingJson.hpp>

namespace livegarnet
{
	CLive2DModel::CLive2DModel():
		m_ModelSetting(nullptr),
		m_UserModel(nullptr)
	{
	}

	CLive2DModel::~CLive2DModel()
	{
	}

	bool CLive2DModel::Load(const std::string& model3Path)
	{
		// model3.jsonÇÃì«Ç›çûÇ›
		resource::CFile File = resource::CFile(model3Path);
		if (!File.LoadImmediate()) return false;

		const auto& data = File.GetData();
		m_ModelSetting = std::make_shared<Csm::CubismModelSettingJson>(&data[0], data.size());

		// moc3
		if (!LoadMoc3(File.GetDirectory())) return false;

		return true;
	}

	bool CLive2DModel::Update()
	{
		return true;
	}

	bool CLive2DModel::Draw()
	{
		return true;
	}

	bool CLive2DModel::LoadMoc3(const std::string& Directory)
	{
		if (!m_ModelSetting) return false;

		m_UserModel = std::make_shared<Csm::CubismUserModel>();

		// moc3ÉtÉ@ÉCÉãÇÃì«Ç›çûÇ›
		std::string moc3Path = Directory + m_ModelSetting->GetModelFileName();

		resource::CFile File = resource::CFile(moc3Path);
		if (!File.LoadImmediate()) return false;

		const auto& data = File.GetData();

		m_UserModel->LoadModel(&data[0], data.size());

		return true;
	}
}