define ["jquery"], ($) ->
  images = for i in [1..176] by 5
    iStr = "#{i}"
    iStr = ("0" for [iStr.length..4]).join() + iStr

    "images/#{iStr}.png"

  $ ->
    $container = $ "#container"
    $container.rotator
      width: 300
      height: 200
      images: images

