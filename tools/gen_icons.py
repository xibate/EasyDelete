"""Draws the addon's textures in EasyDelete/Media/ and the README icon, in the line style of Crescendo's logo.

- Icon.tga: the AddOns list icon, a crimson trash can in a ring, 64x64
- .github/icon.png: the README icon, 256x256

Run: python3 tools/gen_icons.py"""
import os

from PIL import Image, ImageDraw

root = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
media = os.path.join(root, 'EasyDelete', 'Media')
RED = (199, 41, 46, 255)


def trash(draw, p, width, color):
    """A trash can in a 24 unit view box, like the mockups' SVG icons. p maps view box units to pixels"""

    def line(*points):
        draw.line([p(*point) for point in points], fill=color, width=width, joint='curve')
        for point in points:
            x, y = p(*point)
            draw.ellipse([x - width / 2, y - width / 2, x + width / 2, y + width / 2], fill=color)

    line((4, 6.5), (20, 6.5))
    line((9.5, 6.5), (9.5, 4), (14.5, 4), (14.5, 6.5))
    line((6.5, 6.5), (7.5, 20.5), (16.5, 20.5), (17.5, 6.5))
    line((10.25, 10), (10.25, 17))
    line((13.75, 10), (13.75, 17))


def icon(size):
    """The trash can in a ring, drawn 8 times bigger and scaled down so the lines are smooth"""
    big = size * 8
    image = Image.new('RGBA', (big, big), (255, 255, 255, 0))
    draw = ImageDraw.Draw(image)
    ring = big * 0.055
    margin = ring / 2 + big * 0.03
    # Filled with the dark of the dialog, like Crescendo's logo
    draw.ellipse([margin, margin, big - margin, big - margin], fill=(23, 20, 16, 255), outline=RED, width=round(ring))
    # The can fills the middle 56% of the ring
    unit = big * 0.56 / 24
    offset = (big - 24 * unit) / 2

    def p(x, y):
        return (offset + x * unit, offset + y * unit)

    trash(draw, p, round(big * 0.05), RED)
    return image.resize((size, size), Image.LANCZOS)


icon(64).save(os.path.join(media, 'Icon.tga'))
icon(256).save(os.path.join(root, '.github', 'icon.png'))
print('icons written to', os.path.abspath(media))
