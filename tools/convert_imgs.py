import sys
from pathlib import Path

from PIL import Image


def resize_image(input_path: str, output_path: str, size: tuple[int, int] = (96, 96)):
    """将输入图片调整为指定大小并保存为输出路径"""
    print(f"处理图片: {input_path}")
    img = Image.open(input_path)
    # 高质量缩小
    img_small = img.resize(size, Image.Resampling.NEAREST)
    img_small.save(output_path)


def batch_resize(input_dir: str, output_dir: str, size: tuple[int, int] = (96, 96)):
    """批量调整图片大小"""
    input_path = Path(input_dir)
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    for img_path in input_path.glob("*.png"):
        print(f"处理图片: {img_path}")
        img_output = output_path / img_path.name
        resize_image(str(img_path), str(img_output), size)


if __name__ == "__main__":
    args = sys.argv[1:]
    # 显示帮助
    if len(args) == 0 or args[0] in ["-h", "--help"]:
        print("用法: python convert_images.py <输入目录> [输出目录] [宽度] [高度]")
        print("示例:")
        print(
            "  python convert_images.py ../assets/original               # 输出到 ./output，默认 32x32"
        )
        print(
            "  python convert_images.py ../assets/original ../exported   # 指定输出目录"
        )
        print(
            "  python convert_images.py ../assets/original ../exported 64 64  # 指定输出尺寸"
        )
        sys.exit(0)

    # 解析参数
    input_dir = args[0]

    if len(args) >= 2:
        output_dir = args[1]
    else:
        output_dir = "./output"  # 默认输出到当前目录下的 output 文件夹

    if len(args) >= 4:
        width = int(args[2])
        height = int(args[3])
        size = (width, height)
    elif len(args) >= 3:
        # 如果只给了一个数字，视为正方形
        size = (int(args[2]), int(args[2]))
    else:
        size = (96, 96)  # 默认 32x32

    print(f"输入目录: {input_dir}")
    print(f"输出目录: {output_dir}")
    print(f"目标尺寸: {size[0]}x{size[1]}")
    print("开始处理...")

    batch_resize(input_dir, output_dir, size)
    print("处理完成！")
