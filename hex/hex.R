library(hexSticker)
library(magick)
library(extrafont)
# loadfonts()
library(sysfonts)
font_add("Bauhaus 93", "BAUHS93.ttf")
font_add("harlow", "HARLOWSI.TTF")
font_families()


i <- image_read_svg(path = "https://openclipart.org/download/220734/Tribal-Kitten-3.svg",
                    width = 350)
sticker(subplot = i, s_x = 1, s_y = 0.85, s_width = 1.3, s_height = 1.3,
        h_fill = "#C0C0C0", h_color = "black",
        # spotlight = TRUE, l_x = 0.5, l_y = 1.5,
        package="tidycat",
        p_family = "harlow",
        p_color = "black", p_size = 29, p_y = 1.625,
        filename = "./hex/tidycat.png")
file.show("./hex/tidycat.png")

usethis::use_logo(img = "./hex/tidycat.png")
