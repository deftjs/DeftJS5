###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* A mixin that marks a class as participating in dependency injection. Used in conjunction with Deft.ioc.Injector.
###
Ext.define( 'Deft.mixin.Injectable',
	extend: 'Ext.Mixin'

	requires: [
		'Deft.core.Class'
		'Deft.ioc.Injector'
		'Deft.log.Logger'
	]

	mixinConfig:
		before:
			constructor: 'onCreate'

	isInjectable: true
	mixinId: 'injectable'

	onCreate: () ->

		objectifyInject = ( Class ) ->

			unless Class
				return {}
				injectBase = objectifyInject( Class.superclass )
			else
				injectBase = {}

			inject = Class.inject || {}

			# Convert String/Array to Object for injection
			inject = [ inject ] if Ext.isString( inject )
			if Ext.isArray( inject )
				injectObject = {}
				for id in inject
					injectObject[ id ] = id
				inject = injectObject

			Ext.applyIf( inject, objectifyInject( Class.superclass ) )

		@inject = objectifyInject( @ )

		unless @$injected
			Deft.Injector.inject( @inject, @, arguments, false )
			@$injected = true

)
