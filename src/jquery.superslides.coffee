Superslides = (el, options = {}) ->
  @options = $.extend
    delay: 5000
    play: false
    slide_speed: 'normal'
    slide_easing: 'linear'
    nav_class: 'slides-navigation'
    container_class: 'slides-container'
    pagination: false
    hashchange: false
    scrollable: true
  , options

  that       = this
  $window    = $(window)
  $container = $(".#{@options.container_class}")
  $children  = $container.children()
  $control   = $('<div>', class: 'slides-control')
  multiplier = 1
  init       = false
  width      = $window.width()
  height     = $window.height()

  # Private
  initialize = =>
    return if init

    init = true
    multiplier = findMultiplier()
    positions()
    @mobile = navigator.userAgent.match(/mobile/i)

    $control = $container.wrap($control)

    # setupContainers()
    # setupChildren()

    $container.trigger('slides.init')
    @start()
    this

  findMultiplier = =>
    if @size() == 1 then 1 else 3

  next = =>
    index = @current + 1
    index = 0 if index == @size()
    index

  prev = =>
    index = @current - 1
    index = @size() - 1 if index == -1
    index

  parse = (direction) =>
    switch true
      when /next/.test(direction)
        next()

      when /prev/.test(direction)
        prev()

      when /\d/.test(direction)
        direction

      else #bogus
        next()

  parseHash = (hash = window.location.hash) =>
    hash = hash.replace(/^#/, '')
    +hash if hash

  positions = (current) =>
    @current = current || 0
    @next    = next()
    @prev    = prev()
    false

  setupContainers = ->
    $control.css
      width: width * multiplier
      height: height
      left: -width # if @size() > 1

  setupChildren = =>
    # if @size() > 1
    $children.not('.current').css
      display: 'none'
      position: 'absolute'
      overflow: 'hidden'
      top: 0
      left: width
      zIndex: 0

    adjustSlidesSize $children

  adjustSlidesSize = ($el) =>
    that = this
    $el.each (i) ->
      $(this).width(width).height(height)

      # if that.size() > 1
      $(this).css
        left: width

      # adjustImagePosition $('img', this).not('.keep-original')

    # $container.trigger('slides.sized')

  animator = (callback) =>
    that     = this
    position = width * 2
    offset   = -position

    $children.removeClass('current')
    $children.eq(@next).addClass('current').css
      left: position
      display: 'block'

    $control.animate
      useTranslate3d: @mobile
      left: offset
    , options.slide_speed
    , options.slide_easing
    , =>
      callback() if typeof callback == 'function'

      positions(@next)
      @animating = false
      $container.trigger('slides.animated')


  # Public
  @$el = $(el)

  @update = =>
    positions()
    $container.trigger('slides.changed')

  @destroy = =>
    $(el).removeData()

  @size = =>
    $container.children().length

  @stop = =>
    clearInterval @play_id
    delete @play_id

  @start = =>
    $window.trigger 'hashchange'
    @animate 'next', =>
      $container.fadeIn('fast')

    if @options.play
      @stop() if @play_id

      @play_id = setInterval =>
        # @animate 'next'
        false
      , options.delay

    $container.trigger('slides.started')

  @animate = (direction = 'next', callback) =>
    return if @animating

    @animating = true
    index      = parse(direction)
    return if index > @size()

    # Reset positions
    positions(index - 1) if index == direction

    animator(callback)

  # Events
  $window.on 'hashchange', (e) ->
    index = parseHash()
    that.animate(index) if index

  initialize()

# Plugin
name = 'superslides'
$.fn[name] = (option, args) ->
  if typeof option is "string"
    $this = $(this)
    data = $this.data(name)

    method = data[option]
    if typeof method == 'function'
      method = method.call($this, args)
    return method

  @each ->
    $this = $(this)
    data = $this.data(name)
    options = typeof option == 'object' && option

    $this.data name, (data = new Superslides(this, options)) unless data