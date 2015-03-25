###!
sarine.viewer.dynamic.light - v0.0.7 -  Wednesday, March 25th, 2015, 5:38:48 PM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.
###
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
		defer.notify(@id + " : start load all images")

		@loadParts().then(defer.resolve) 
		#$.when.apply($, allDeferreds).done(defer.resolve) 		
		defer	

	nextImage : ()->
		indexer = Object.getOwnPropertyNames(downloadImagesArr).map((v)-> parseInt(v)) 
		if indexer.length > 1
			@ctx.clearRect 0, 0, @canvas.width(), @canvas.height()
			@ctx.drawImage downloadImagesArr[indexer[counter]] , 0 , 0			
			counter = (counter + 1) % indexer.length			

@Light = Light
