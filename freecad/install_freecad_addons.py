import FreeCAD
import FreeCADGui
import AddonManager

def install_addons():
    addon_manager = AddonManager.AddonManager()
    addons_to_install = [
        "A2plus",
        "Fasteners",
        "Assembly4",
        "SheetMetal",
        "Curves"
    ]
    
    for addon in addons_to_install:
        addon_manager.install(addon)

if __name__ == "__main__":
    install_addons()
