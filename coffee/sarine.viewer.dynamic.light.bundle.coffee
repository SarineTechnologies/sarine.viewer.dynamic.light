###!
sarine.viewer.dynamic.light - v0.2.0 -  Sunday, October 8th, 2017, 11:02:37 AM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.
###

class Viewer
  rm = ResourceManager.getInstance();
  constructor: (options) ->
    console.log("")
    @first_init_defer = $.Deferred()
    @full_init_defer = $.Deferred()
    {@src, @element,@autoPlay,@callbackPic} = options
    @id = @element[0].id;
    @element = @convertElement()
    Object.getOwnPropertyNames(Viewer.prototype).forEach((k)-> 
      if @[k].name == "Error" 
          console.error @id, k, "Must be implement" , @
    ,
      @)
    @element.data "class", @
    @element.on "play", (e)-> $(e.target).data("class").play.apply($(e.target).data("class"),[true])
    @element.on "stop", (e)-> $(e.target).data("class").stop.apply($(e.target).data("class"),[true])
    @element.on "cancel", (e)-> $(e.target).data("class").cancel().apply($(e.target).data("class"),[true])
  error = () ->
    console.error(@id,"must be implement" )
  first_init: Error
  full_init: Error
  play: Error
  stop: Error
  convertElement : Error
  cancel : ()-> rm.cancel(@)
  loadImage : (src)-> rm.loadImage.apply(@,[src])
  setTimeout : (delay,callback)-> rm.setTimeout.apply(@,[@delay,callback]) 
    
@Viewer = Viewer 

class Viewer.Dynamic extends Viewer
	@playing = false
	nextImage : Error

	constructor: (options) -> 
		super(options)
		@delay = 50
		Object.getOwnPropertyNames(Viewer.Dynamic.prototype).forEach((k)-> 
			if @[k].name == "Error" 
				console.error @id, k, "Must be implement" , @
		,
			@)
	play: (force,delay) ->
		if force
			@playing = true;
		@nextImage.apply(@) 
		if(@playing)
			_t = @ 
			@setTimeout(@delay,_t.play)   
	stop: ()-> 
		@playing = false


 

class Light extends Viewer.Dynamic

	amountOfImages = 48
	imageIndex = 0	
	allDeferreds = {} 
	imagesArr = {}
	downloadImagesArr = {}
	isEven = true
	setSpeed = 100
	speed = 100
	sliceCount = 0
	counter = 1
	spriteImg = null

	constructor: (options) ->
		super(options)						
		{@sliceDownload} = options
		@sliceDownload = @sliceDownload | 3
		@imagesArr = {}
		@downloadImagesArr = {}
		@first_init_defer = $.Deferred()
		@full_init_defer = $.Deferred()
		for index in [0..amountOfImages]
			@imagesArr[index] = undefined

	convertElement : () ->
		@canvas = $("<canvas>")		
		@ctx = @canvas[0].getContext('2d')
		@element.append(@canvas)		

	first_init : ()->
		defer = @first_init_defer
		defer.notify(@id + " : start load first image")
		_t = @
		@loadImage(@src + "00.png").then((img)->
			_t.canvas.attr {'width':img.width, 'height': img.height}
			_t.ctx.drawImage img , 0 , 0 			
			
			# try load the sprite image.
			# if not exist, use the old method of multiple images.
			spriteImg = new Image()
			spriteImg.onload = (e) ->
				defer.resolve(_t)
			
			spriteImg.onerror = (e) ->
				spriteImg = null
				defer.resolve(_t)
			
			spriteImg.src = _t.src + "sprite.png"

			return
		)
		defer
	loadParts : (gap,defer)->
		gap = gap || 0
		defer = defer || $.Deferred()
		downloadImages = []
		_t = @
		$.when.apply($,for index in (index for index in Object.getOwnPropertyNames(@imagesArr) when (index + gap) % @sliceDownload == 0)
			do (index)->
				_t.loadImage(_t.src + (if index < 10 then "0" + index else index)  + ".png").then((img)-> downloadImages.push img )
			).then(()->
					for img in downloadImages
						do (img)->
							index = parseInt(img.src.match(/\d+(?=.png)/)[0])
							downloadImagesArr[index] = imagesArr[index] = img
					if Object.getOwnPropertyNames(imagesArr).length == (amountOfImages + 1)
						defer.resolve(_t)
					else
						_t.loadParts(++gap,defer)
					_t.delay = (_t.sliceDownload / gap) * setSpeed  
				)
		return defer

	full_init : ()->
		defer = @full_init_defer
		if spriteImg is null
			defer.notify(@id + " : start load all images")

			@loadParts().then(defer.resolve) 
			#$.when.apply($, allDeferreds).done(defer.resolve)
		defer	

	nextImage : ()->
		indexer = Object.getOwnPropertyNames(downloadImagesArr).map((v)-> parseInt(v)) 
		if indexer.length > 1
			@ctx.clearRect 0, 0, @ctx.canvas.width, @ctx.canvas.height
			@ctx.drawImage downloadImagesArr[indexer[counter]] , 0 , 0			
			counter = (counter + 1) % indexer.length			

	play : ()->
		if spriteImg is null
			super(true)
		else
			# In interval, Load the sprite image to the canvas and move the x axis to the right till the end, and return 
			# to the start.
			xPosition = 0
			_t = @

			intervalCallback = () ->
				_t.ctx.clearRect xPosition, 0, _t.ctx.canvas.width, _t.ctx.canvas.height
				_t.ctx.drawImage spriteImg, xPosition, 0,_t.ctx.canvas.width,_t.ctx.canvas.height,0,0,_t.ctx.canvas.width,_t.ctx.canvas.height

				# last image, return to the start
				if imageIndex <= amountOfImages
					xPosition += _t.ctx.canvas.width
					imageIndex++
				else
					imageIndex = 0
					xPosition = 0

				return
				
			setInterval intervalCallback,speed

		return

@Light = Light


