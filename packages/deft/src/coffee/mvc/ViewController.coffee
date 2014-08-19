###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
A lightweight MVC view controller. Full usage instructions in the [DeftJS documentation](https://github.com/deftjs/DeftJS/wiki/ViewController).

First, specify a ViewController to attach to a view:

		Ext.define("DeftQuickStart.view.MyTabPanel", {
			extend: "Ext.tab.Panel",
			controller: "DeftQuickStart.controller.MainController",
			...
		});

Next, define the ViewController:

		Ext.define("DeftQuickStart.controller.MainController", {
			extend: "Deft.mvc.ViewController",

			init: function() {
				return this.callParent(arguments);
			}

		});

## Inject dependencies using the <u>[`inject` property](https://github.com/deftjs/DeftJS/wiki/Injecting-Dependencies)</u>:

		Ext.define("DeftQuickStart.controller.MainController", {
			extend: "Deft.mvc.ViewController",
			inject: ["companyStore"],

			config: {
				companyStore: null
			},

			init: function() {
				return this.callParent(arguments);
			}

		});

## Define <u>[references to view components](https://github.com/deftjs/DeftJS/wiki/Accessing-Views)</u> and <u>[add view listeners](https://github.com/deftjs/DeftJS/wiki/Handling-View-Events)</u> with the `control` property:

		Ext.define("DeftQuickStart.controller.MainController", {
			extend: "Deft.mvc.ViewController",

			control: {

				// Most common configuration, using an itemId and listener
				manufacturingFilter: {
					change: "onFilterChange"
				},

				// Reference only, with no listeners
				serviceIndustryFilter: true,

				// Configuration using selector, listeners, and event listener options
				salesFilter: {
					selector: "toolbar > checkbox",
					listeners: {
						change: {
							fn: "onFilterChange",
							buffer: 50,
							single: true
						}
					}
				}
			},

			init: function() {
				return this.callParent(arguments);
			}

			// Event handlers or other methods here...

		});

## Dynamically monitor view to attach listeners to added components with <u>[live selectors](https://github.com/deftjs/DeftJS/wiki/ViewController-Live-Selectors)</u>:

		control: {
			manufacturingFilter: {
				live: true,
				listeners: {
					change: "onFilterChange"
				}
			}
		};

## Observe events on injected objects with the <u>[`observe` property](https://github.com/deftjs/DeftJS/wiki/ViewController-Observe-Configuration)</u>:

		Ext.define("DeftQuickStart.controller.MainController", {
			extend: "Deft.mvc.ViewController",
			inject: ["companyStore"],

			config: {
				companyStore: null
			},

			observe: {
				// Observe companyStore for the update event
				companyStore: {
					update: "onCompanyStoreUpdateEvent"
				}
			},

			init: function() {
				return this.callParent(arguments);
			},

			onCompanyStoreUpdateEvent: function(store, model, operation, fieldNames) {
				// Do something when store fires update event
			}

		});

## Attach companion view controllers using the <u>[`companions` property](https://github.com/deftjs/DeftJS/wiki/ViewController-Companion-Configuration)</u>:

		Ext.define("DeftQuickStart.controller.MainController", {
			extend: "Deft.mvc.ViewController",
			inject: ["companyStore"],

			config: {
				companyStore: null
			},

			companions: {
				// Create companion view controllers which can also manage the original view
				// This allows a view controller to leverage common behavior provided by other view controllers.
				shoppingCart: "DeftQuickStart.controller.ShoppingCartController"
			},

			init: function() {
				return this.callParent(arguments);
			}

		});

###
Ext.define( 'Deft.mvc.ViewController',
	extend: 'Ext.app.ViewController'
	alternateClassName: [ 'Deft.ViewController' ]
	mixins: [ 'Deft.mixin.Injectable', 'Deft.mixin.Observer' ]
	requires: [
		'Deft.core.Class'
		'Deft.log.Logger'
		'Deft.mvc.ComponentSelector'
		'Deft.mixin.Injectable'
		'Deft.mixin.Observer'
		'Deft.mvc.Observer'
		'Deft.util.DeftMixinUtils'
	]


	config:
		###*
		* @private
		* Companion ViewController instances.
		###
		companionInstances: null


	constructor: ( config = {} ) ->
		if Ext.isObject( config.companions )
			@companions = Ext.merge( @companions, config.companions )
			delete config.companions

		# Core Sencha VC logic, including initConfig() call, happens in superclass constructor, so call it first.
		@callParent( arguments )
		@createObservers()
		return @


	###*
	* @protected
	###
	createCompanions: ->
		@companionInstances = {}

		for alias, clazz of @companions
			@addCompanion( alias, clazz )


	###*
	* @protected
	###
	destroyCompanions: ->
		for alias, instance of @companionInstances
			@removeCompanion( alias )


	###*
	* Add a new companion view controller to this view controller.
	* @param {String} alias The alias for the new companion.
	* @param {String} class The class name of the companion view controller.
	###
	addCompanion: ( alias, clazz ) ->

		if( @companionInstances[ alias ]? )
			Deft.Logger.warn( "The specified companion alias '#{ alias }' already exists." )
			return

		isRecursionStart = false
		if( Deft.mvc.ViewController.companionCreationStack.length is 0 )
			isRecursionStart = true

		try

			# Prevent circular dependencies during companion creation
			if( not Ext.Array.contains( Deft.mvc.ViewController.companionCreationStack, Ext.getClassName( @ ) ) )
				Deft.mvc.ViewController.companionCreationStack.push( Ext.getClassName( @ ) )
			else
				Deft.mvc.ViewController.companionCreationStack.push( Ext.getClassName( @ ) )
				initialClass = Deft.mvc.ViewController.companionCreationStack[ 0 ]
				stackMessage = Deft.mvc.ViewController.companionCreationStack.join( " -> " )
				Deft.mvc.ViewController.companionCreationStack = []
				Ext.Error.raise( msg: "Error creating companions for '#{ initialClass }'. A circular dependency exists in its companions: #{ stackMessage }" )

			newHost = Ext.create( clazz )
			newHost.setView( @getView() )
			@companionInstances[ alias ] = newHost
			Deft.mvc.ViewController.companionCreationStack = [] if isRecursionStart

		catch error
			# NOTE: Ext.Logger.error() will throw an error, masking the error we intend to rethrow, so warn instead.
			Deft.Logger.warn( "Error initializing associated view controller: an error occurred while creating an instance of the specified controller: '#{ clazz }'." )
			Deft.mvc.ViewController.companionCreationStack = []
			throw error


	###*
	* Removes and destroys a companion view controller from this view controller.
	* @param {String} alias The alias for the companion host to remove
	###
	removeCompanion: ( alias ) ->

		if( not @companionInstances[ alias ]? )
			Deft.Logger.warn( "The specified companion alias '#{ alias }' cannot be removed because the alias does not exist." )

		try
			@companionInstances[ alias ]?.destroy()
			delete @companionInstances[ alias ]

		catch error
			# NOTE: Ext.Logger.error() will throw an error, masking the error we intend to rethrow, so warn instead.
			Deft.Logger.warn( "Error destroying associated view controller: an error occurred while destroying the associated controller with the alias '#{ alias }'." )
			throw error


	###*
	* Locates a companion view controller by alias.
	* @param {String} alias The alias for the desired companion instance
	* @return {Deft.mvc.ViewController} The companion view controller instance.
	###
	getCompanion: ( alias ) ->
		return @companionInstances[ alias ]


	###*
	* Destroy the ViewController
	###
	destroy: ->
		@callParent( arguments )
		@removeObservers()
		@destroyCompanions()
		return true


	###*
	* @private
	###
	onViewBeforeDestroy: ->
		view = @getView()
		if( @destroy() )
			view.un( 'beforedestroy', @onViewBeforeDestroy, @ )
			return true
		return false


	###*
	* Get the component(s) corresponding to the specified view-relative selector.
	###
	getViewComponent: ( selector ) ->
		if selector?
			matches = Ext.ComponentQuery.query( selector, @getView() )
			if matches.length is 0
				return null
			else if matches.length is 1
				return matches[ 0 ]
			else
				return matches
		else
			return @getView()


	onClassExtended: ( clazz, config ) ->
		clazz.override(
			constructor: Deft.mvc.ViewController.mergeSubclassInterceptor()
		)
		return true


	privates:
		setView: ( view ) ->
			@callParent( arguments )

			if( Ext.getVersion( 'extjs' )? )
				# Ext JS
				@getView().on( 'beforedestroy', @onViewBeforeDestroy, @ )

			else
				# Sencha Touch
				self = @
				originalViewDestroyFunction = @getView().destroy
				@getView().destroy = ->
					if self.destroy()
						originalViewDestroyFunction.call( @ )
					return

			@createCompanions()
			return


	statics:

		companionCreationStack: []
		PREPROCESSING_COMPLETED_KEY: "$viewcontroller_processed"


		mergeSubclassInterceptor: () ->
			return ( config = {} ) ->

				companionPropertyName = "companions"
				if not @[ companionPropertyName ]? then @[ companionPropertyName ] = {}

				if( not @[ Deft.mvc.ViewController.PREPROCESSING_COMPLETED_KEY ] )

					if( Ext.Object.getSize( @[ companionPropertyName ] ) > 0 )
						Deft.util.DeftMixinUtils.mergeSuperclassProperty( @, companionPropertyName, Deft.mvc.ViewController.companionMergeHandler )

					@[ Deft.mvc.ViewController.PREPROCESSING_COMPLETED_KEY ] = true

				@[ Deft.util.DeftMixinUtils.parentConstructorForVersion() ]( arguments )
				return @


		companionMergeHandler: ( parentCompanions, childCompanions ) ->
			return Ext.merge( Ext.clone( parentCompanions ), Ext.clone( childCompanions ) )
)
