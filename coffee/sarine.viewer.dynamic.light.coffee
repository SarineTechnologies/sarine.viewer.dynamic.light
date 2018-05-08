
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
			
			# # try load the sprite image.
			# # if not exist, use the old method of multiple images.
			# if(!Device.isHTTP2())
			# 	spriteImg = new Image()
			# 	spriteImg.onload = (e) ->
			# 		_t.canvas.attr {'width':spriteImg.width / (amountOfImages + 1), 'height': spriteImg.height}
			# 		defer.resolve(_t)

			# 	spriteImg.onerror = (e) ->
			# 		spriteImg = null
			# 		defer.resolve(_t)

			# 	spriteImg.src = _t.src.replace("Viewer", "Sprite") + "sprites.png";
			# else
			# 	defer.resolve(_t) 
			# return
			defer.resolve(_t)
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
		_t = @

		# try load the sprite image.
		# if not exist, use the old method of multiple images.
		if(!Device.isHTTP2())
			spriteImg = new Image()
			spriteImg.onload = (e) ->
				_t.canvas.attr {'width':spriteImg.width / (amountOfImages + 1), 'height': spriteImg.height}
				defer.resolve(_t)

			spriteImg.onerror = (e) ->
				spriteImg = null
				defer.resolve(_t)

			spriteImg.src = _t.src.replace("Viewer", "Sprite") + "sprites.png";
		
		if spriteImg is null
			defer.notify(@id + " : start load all images")

			@loadParts().then(defer.resolve) 
			#$.when.apply($, allDeferreds).done(defer.resolve)
		else
			defer.resolve(_t)
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
			spriteDirection = null

			intervalCallback = () ->

				if imageIndex == 0
					spriteDirection = "rtl"
				if imageIndex == amountOfImages
					spriteDirection = "ltr"

				_t.ctx.clearRect 0, 0, _t.ctx.canvas.width, _t.ctx.canvas.height
				_t.ctx.drawImage spriteImg, xPosition, 0,_t.ctx.canvas.width,_t.ctx.canvas.height,0,0,_t.ctx.canvas.width,_t.ctx.canvas.height

				# last image, return to the start
				# if imageIndex <= amountOfImages
				if spriteDirection == "rtl"
					xPosition += _t.ctx.canvas.width
					imageIndex++
				else
					imageIndex--
					xPosition -= _t.ctx.canvas.width

				return
				
			setInterval intervalCallback,150

		return

@Light = Light
