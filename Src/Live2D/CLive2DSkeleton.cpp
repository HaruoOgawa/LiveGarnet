#include "CLive2DSkeleton.h"
#include <Id/CubismIdManager.hpp>

namespace livegarnet
{
	CLive2DSkeleton::CLive2DSkeleton()
	{
	}

	CLive2DSkeleton::~CLive2DSkeleton()
	{
	}

	void CLive2DSkeleton::Create()
	{
		// 標準パラメーターをもとにボーンマップを作製
		// https://docs.live2d.com/cubism-editor-manual/standard-parameter-list/
		CreateCommonBoneList();
	}

	bool CLive2DSkeleton::SetCommonBoneValue(const std::string& Name, float Value, float Rate)
	{
		const auto& it = m_CommonBoneMap.find(Name);
		if (it == m_CommonBoneMap.end()) return false;

		auto& Bone = m_CommonBoneMap[Name];

		float Result = fmaxf(fminf(Value, Bone.Max), Bone.Min);
		Result = (1.0f - Rate) * Bone.Value + Rate * Result;

		// このボーンは今後更新値を使うことを宣言
		Bone.Updated = true;
		Bone.Value = Result;

		return true;
	}

	bool CLive2DSkeleton::GetCommonBoneValue(const std::string& Name) const
	{
		const auto& it = m_CommonBoneMap.find(Name);
		if (it == m_CommonBoneMap.end()) return 0.0f;

		return it->second.Value;
	}

	bool CLive2DSkeleton::Update(CubismModel* _model)
	{
		for (const auto& Pair : m_CommonBoneMap)
		{
			const auto& Name = Pair.first;
			if (Name.empty()) continue;

			const auto& Bone = Pair.second;
			if (!Bone.Updated) continue;

			_model->SetParameterValue(CubismFramework::GetIdManager()->GetId(Name.c_str()), Bone.Value);
		}

		return true;
	}

	void CLive2DSkeleton::CreateCommonBoneList()
	{
		// 標準パラメーターをもとにボーンマップを作製
		// https://docs.live2d.com/cubism-editor-manual/standard-parameter-list/
		m_CommonBoneMap = {
			// 顔の向き(モーションキャプチャで動かす)
			{"ParamAngleX", SLive2DBone(-30.0f, 0.0f, 30.0f)}, 
			{"ParamAngleY", SLive2DBone(-30.0f, 0.0f, 30.0f)},
			{"ParamAngleZ", SLive2DBone(-30.0f, 0.0f, 30.0f)},

			// 顔のパーツ(モーションキャプチャで動かす)
			{"ParamEyeLOpen", SLive2DBone(0.0f, 1.0f, 1.0f)},
			{"ParamEyeLSmile", SLive2DBone(0.0f, 0.0f, 1.0f)},
			{"ParamEyeROpen", SLive2DBone(0.0f, -30.0f, 30.0f)},
			{"ParamEyeRSmile", SLive2DBone(0.0f, 0.0f, 1.0f)},
			{"ParamEyeBallX", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamEyeBallY", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamEyeBallForm", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamBrowLY", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamBrowRY", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamBrowLX", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamBrowRX", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamBrowLAngle", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamBrowRAngle", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamBrowLForm", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamBrowRForm", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamMouthForm", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamMouthOpenY", SLive2DBone(0.0f, 0.0f, 1.0f)},
			{"ParamCheek", SLive2DBone(0.0f, 0.0f, 1.0f)},

			// 体の回転(モーションキャプチャで動かす)
			{"ParamBodyAngleX", SLive2DBone(-10.0f, 0.0f, 10.0f)}, 
			{"ParamBodyAngleY", SLive2DBone(-10.0f, 0.0f, 10.0f)},
			{"ParamBodyAngleZ", SLive2DBone(-10.0f, 0.0f, 10.0f)},

			// 呼吸
			{"ParamBreath", SLive2DBone(0.0f, 0.0f, 1.0f)},

			// 腕(モーションキャプチャで動かす)
			{"ParamArmLA", SLive2DBone(-30.0f, 0.0f, 30.0f)},
			{"ParamArmRA", SLive2DBone(-30.0f, 0.0f, 30.0f)},
			{"ParamArmLB", SLive2DBone(-30.0f, 0.0f, 30.0f)},
			{"ParamArmRB", SLive2DBone(-30.0f, 0.0f, 30.0f)},

			// 手(モーションキャプチャで動かす)
			{"ParamHandL", SLive2DBone(-10.0f, 0.0f, 10.0f)},
			{"ParamHandR", SLive2DBone(-10.0f, 0.0f, 10.0f)},

			// 髪
			{"ParamHairFront", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamHairSide", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamHairBack", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamHairFluffy", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			
			// 肩をすくめる
			{"ParamShoulderY", SLive2DBone(-10.0f, 0.0f, 10.0f)},
			
			// 胸揺れ
			{"ParamBustX", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			{"ParamBustY", SLive2DBone(-1.0f, 0.0f, 1.0f)},
			
			// 全体の左右位置
			{"ParamBaseX", SLive2DBone(-10.0f, 0.0f, 10.0f)},

			// 全体の上下位置
			{"ParamBaseY", SLive2DBone(-10.0f, 0.0f, 10.0f)},
		};
	}
}