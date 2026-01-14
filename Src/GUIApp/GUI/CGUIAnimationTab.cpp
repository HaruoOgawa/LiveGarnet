#ifdef USE_GUIENGINE

#include "CGUIAnimationTab.h"
#include <Animation/CSkeleton.h>
#include <Animation/CAnimationClipSet.h>
#include <Scene/CSceneController.h>

namespace gui
{
	bool CGUIAnimationTab::DrawTab(const std::shared_ptr<animation::CSkeleton>& Skeleton)
	{
		if (ImGui::BeginTabItem("Animation"))
		{
			if (!CGUIAnimationTab::DrawSkeleton(Skeleton)) return false;

			ImGui::EndTabItem();
		}

		return true;
	}

	bool CGUIAnimationTab::DrawClipList(const SGUIParams& GUIParams)
	{
		const auto& SceneController = GUIParams.SceneController;
		if (!SceneController) return true;

		if (ImGui::BeginTabItem("AnimationClip"))
		{
			for (const auto& ClipSet : SceneController->GetAnimationClipSetMap())
			{
				for (const auto& AnimationClip : ClipSet.second->GetAnimationClipList())
				{
					if (!DrawSkeleton(AnimationClip->GetDefaultSkeleton())) return false;
				}
			}

			ImGui::EndTabItem();
		}

		return true;
	}

	bool CGUIAnimationTab::DrawSkeleton(const std::shared_ptr<animation::CSkeleton>& Skeleton)
	{
		if (!Skeleton) return true;

		std::string TreeLabel = Skeleton->GetName() + "##" + "DrawSkeleton_CGUIAnimationTab";
		if (ImGui::TreeNodeEx(TreeLabel.c_str(), ImGuiTreeNodeFlags_Framed))
		{
			// Rig
			const animation::ERigType RigType = Skeleton->GetRig();
			{
				if (ImGui::BeginCombo("RigType##DrawSkeleton_CGUIAnimationTab", GetStrFromRigType(RigType).c_str()))
				{
					for (int i = 0; i < static_cast<int>(animation::ERigType::Max); i++)
					{
						animation::ERigType CurrentRigType = static_cast<animation::ERigType>(i);

						const bool IsSelected = (RigType == CurrentRigType);

						if (ImGui::Selectable(GetStrFromRigType(CurrentRigType).c_str(), IsSelected) && !IsSelected)
						{
							Skeleton->SetRig(CurrentRigType);
						}
					}

					ImGui::EndCombo();
				}
			}

			// HumanoidBone
			if (ImGui::BeginChild("HumanoidBone##DrawSkeleton_CGUIAnimationTab", ImVec2(ImGui::GetContentRegionAvail().x, 0), ImGuiChildFlags_Border, 0))
			{
				const auto& HumanoidBoneTable = Skeleton->GetHumanoidBoneTable();
				const auto& BoneList = Skeleton->GetBoneList();

				for (int n = 0; n < static_cast<int>(animation::EHumanoidBones::Max); n++)
				{
					// BoneName Label
					animation::EHumanoidBones BoneName = static_cast<animation::EHumanoidBones>(n);
					std::string BoneName_Str = animation::CSkeleton::CastHumanoidBonesToString(BoneName);

					ImGui::Text(BoneName_Str.c_str());

					ImGui::SameLine();

					// NodeName
					auto it = HumanoidBoneTable.find(BoneName);
					std::string NodeName = std::string();

					if (it != HumanoidBoneTable.end())
					{
						NodeName = it->second->GetBoneNode()->GetName();
					}

					//
					std::string ComboLabel = "NodeName##DrawSkeleton_CGUIAnimationTab_" + BoneName_Str;
					if (ImGui::BeginCombo(ComboLabel.c_str(), NodeName.c_str()))
					{
						for (int i = 0; i < static_cast<int>(BoneList.size()); i++)
						{
							const auto& it2 = BoneList[i];

							std::string CurrentNodeName = std::get<0>(it2);
							const bool IsSelected = (NodeName == CurrentNodeName);

							if (ImGui::Selectable(CurrentNodeName.c_str(), IsSelected) && !IsSelected)
							{
								Skeleton->AddHumanoidBone(BoneName, std::get<1>(it2));
							}
						}

						ImGui::EndCombo();
					}
				}

				ImGui::EndChild();
			}

			ImGui::TreePop();
		}

		return true;
	}

	std::string CGUIAnimationTab::GetStrFromRigType(animation::ERigType RigType)
	{
		switch (RigType)
		{
		case animation::ERigType::Humanoid:
			return "Humanoid";
		case animation::ERigType::None:
		default:
			return "None";
		}
	}
}
#endif