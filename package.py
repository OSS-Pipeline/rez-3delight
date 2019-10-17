name = "3delight"

version = "1.6.13"

authors = [
    "DNA Research"
]

description = \
    """
    3Delight is a CPU-based path tracer, fully built on the new NSI standard and OSL.
    """

requires = [
    "cmake-3+",
    "license_manager"
]

variants = [
    ["platform-linux"]
]

tools = [
    "i-display",
    "licserver",
    "licutils",
    "nsidepends",
    "oslc",
    "renderdl",
    "tdlmake"
]

build_system = "cmake"

with scope("config") as config:
    config.build_thread_count = "logical_cores"

uuid = "3delight-{version}".format(version=str(version))

def commands():
    # We setup the correct environment variable in place of the ".3delight_bash" script coming with 3Delight.
    env.PATH.prepend("{root}/bin")
    env.LD_LIBRARY_PATH.prepend("{root}/lib")
    env.DELIGHT.append("{root}")
    env.MAYA_MODULE_PATH.append("{root}/maya/modules")
    env.MAYA_RENDER_DESC_PATH.append("{root}/maya/render_desc")
    env.KATANA_RESOURCES.append("{root}/3DelightForKatana")
    env.DEFAULT_RENDERER.set("dl")
    env.HOUDINI_PATH.append("{root}/houdini/17.5")

    # Helper environment variables.
    env.DELIGHT_BINARY_PATH.set("{root}/bin")
    env.DELIGHT_INCLUDE_PATH.set("{root}/include")
    env.DELIGHT_LIBRARY_PATH.set("{root}/lib")
