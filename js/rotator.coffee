(($) ->
  class RotatorException
    constructor: (@message) ->
    toString: -> "RotatorException: #{@message}"

  class Region
    id: null

    constructor: (bounds, @style = {}, @slides = [], @handlers = {}) ->
      @coords = if _.isString bounds then bounds.split " " else bounds

    makeSvgp: ->
      path = for i in [0..@coords.length - 1] by 2
        x = @coords[i]; y = @coords[i + 1]
        prefix = if 0 == i then "M" else "L"

        "#{prefix}#{x} #{y}"
      path.join(" ") + " Z"

    draw: (paper) ->
      @id = _.uniqueId "region_"

      el = paper
      .path @makeSvgp()
      .attr @style
      .data "type", "path"
      .data "id", @id

      el[eventName] handler for eventName, handler of @handlers

      el

  class Rotator
    @defaults =
      images: []
      defaultImage: null
      width: null, height: null
      totalCircleWidth: 500
      regions: []
      clockwise: yes

    paper: null
    isDragging: no
    prevMouseX: 0
    circleDiff: 0
    currentSlideNum: 0
    regionsBySlides: []

    @preload = (src, onLoad = () ->) ->
      img = new Image()
      img.src = src
      img.onload = onLoad
    # Get global array offset from local
    @arrayOffset = (arr, cur, offset) ->
      l = arr.length
      newOffset = cur + offset
      # Tailrec optimization :D
      newOffset = l + newOffset while newOffset < 0
      newOffset = newOffset - l while newOffset > (l - 1)
      newOffset
    # Returns closest to the @num number in array @arr
    @closest = (arr, num) ->
      closest = null
      for candidate in arr when closest is null or Math.abs(candidate - num) < Math.abs(closest - num)
        closest = candidate

      closest

    constructor: (@$el, @settings) ->
      _.bindAll @, "onMouseDown", "onMouseUp", "onMouseMove", "onLoad"

      imagesCount = settings.images.length
      if imagesCount is 0 then throw new RotatorException "Please define some images to load"

      w = settings.width ? $el.width()
      h = settings.height ? $el.height()

      @paper = Raphael $el.get(0), w, h

      onLoadAll = _.after imagesCount, @onLoad
      Rotator.preload img, onLoadAll for img in settings.images

      defaultBg = settings.defaultImage ? settings.images[0]
      @background = @paper.image defaultBg, 0, 0, w, h
      @background.toBack()

    onLoad: ->
      @regionsBySlides = (@paper.set() for [0..@settings.images.length])

      @addRegion region for region in @settings.regions

      @$el.on mousedown: @onMouseDown

      $ window
      .on
        mouseup: @onMouseUp
        mousemove: @onMouseMove

      @goToSlide 0
      return

    onMouseDown: (e) ->
      @prevMouseX = e.pageX
      @isDragging = yes
      return

    onMouseUp: ->
      @isDragging = no
      return

    onMouseMove: (e) ->
      if @isDragging
        mouseX = e.pageX
        mouseXDiff = (mouseX - @prevMouseX) * (if @settings.clockwise then 1 else -1)
        @prevMouseX = mouseX
        @circleDiff += @settings.images.length / @settings.totalCircleWidth * mouseXDiff
        if 1 < Math.abs @circleDiff
          slideOffset = Math.round @circleDiff
          @circleDiff -= slideOffset

          @goToSlide slideOffset
      return

    animateToSlide: (offset) ->
      if offset == 0 then return

      cb = =>
        nextSlide = if offset > 0 then 1 else -1
        @goToSlide nextSlide
        @animateToSlide offset - nextSlide

      setTimeout cb, 40

    goToSlide: (offset) ->
      images = @settings.images
      newSlideNum = Rotator.arrayOffset images, @currentSlideNum, offset

      @background.attr src: images[newSlideNum]

      for slideNum, s of @regionsBySlides
        if newSlideNum is parseInt slideNum then s.show() else s.hide()

      @currentSlideNum = newSlideNum
      return

    getRegion: (id) ->
      region = null

      for s of @regionsBySlides
        s.forEach (r) -> if id is r.data "id" then region = r; false

      region

    addRegion: (region) ->
      for slide in region.slides
        @regionsBySlides[slide].push region.draw @paper

      return

    removeRegion: (id) ->
      if region = @getRegion id then region.remove()
      return

    getPaper: -> @paper

  $.region = (bounds, style, slides) ->
    slides = unless _.isArray slides then [slides] else slides

    new Region bounds, style, slides

  $.fn.rotator = ->
    args = []
    Array::push.apply args, arguments

    @each ->
      $el = $ @
      data = $el.data()

      unless data.rotator?
        settings = $.extend {}, Rotator.defaults, args[0]
        data.rotator = new Rotator $el, settings
      else if args.length > 0
        data.rotator[args.shift()] args...
      return
  return
)(jQuery)