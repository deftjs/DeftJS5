###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

describe( 'Deft.mvc.ViewController', ->
	
	hasListener = ( observable, eventName ) ->
		return observable.hasListener( eventName )


	describe( 'Observer creation', ->
		
		beforeEach( ->
			Ext.define( 'NestedObservable',
				constructor: ->
					@observable = Ext.create( 'Ext.util.Observable' )
					@callParent( arguments )
			)
			
			Ext.define( 'DeeplyNestedObservable',
				constructor: ->
					@nested = Ext.create( 'NestedObservable' )
					@callParent( arguments )
			)
			
			return
		)

		afterEach( ->
			delete NestedObservable
			delete DeeplyNestedObservable

			return
		)
		
		specify( 'merges child observe configurations', ->
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				observe:
					messageBus:
						baseMessage: 'baseMessageHandler'
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus:
						subclassMessage: 'subclassMessageHandler'
			)
			
			viewController = Ext.create( 'ExampleSubclassViewController' )
			
			expectedObserveConfiguration =
				messageBus:
					subclassMessage: [ 'subclassMessageHandler' ]
					baseMessage: [ 'baseMessageHandler' ]
			
			expect( viewController.observe ).to.deep.equal( expectedObserveConfiguration )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'merges observe configurations when extend when a handler is a list', ->
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				observe:
					messageBus:
						baseMessage: 'baseMessageHandler'
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus:
						subclassMessage: 'subclassMessageHandler1, subclassMessageHandler2'
			)
			
			viewController = Ext.create( 'ExampleSubclassViewController' )
			
			expectedObserveConfiguration =
				messageBus:
					subclassMessage: [ 'subclassMessageHandler1', 'subclassMessageHandler2' ]
					baseMessage: [ 'baseMessageHandler' ]
			
			expect( viewController.observe ).to.deep.equal( expectedObserveConfiguration )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'merges multiple levels of observe configurations throughout a class hierarchy', ->
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				observe:
					messageBus:
						baseMessage: "baseMessageHandler"
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus:
						subclassMessage: "subclassMessageHandler"
			)
			
			Ext.define( 'ExampleSubclass2ViewController',
				extend: 'ExampleSubclassViewController'
				
				observe:
					messageBus:
						subclass2Message: "subclass2MessageHandler"
			)
			
			viewController = Ext.create( 'ExampleSubclass2ViewController' )
			
			expectedObserveConfiguration =
				messageBus:
					subclass2Message: [ 'subclass2MessageHandler' ]
					subclassMessage: [ 'subclassMessageHandler' ]
					baseMessage: [ 'baseMessageHandler' ]
			
			expect( viewController.observe ).to.deep.equal( expectedObserveConfiguration )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController
			delete ExampleSubclass2ViewController

			return
		)
		
		specify( 'merges multiple levels of child observe configurations, with child observers taking precedence', ->
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				observe:
					messageBus:
						baseMessage: 'baseMessageHandler'
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus:
						subclassMessage: 'subclassMessageHandler'
			)
			
			Ext.define( 'ExampleSubclass2ViewController',
				extend: 'ExampleSubclassViewController'
				
				observe:
					messageBus:
						baseMessage: 'subclass2MessageHandler'
			)
			
			viewController = Ext.create( 'ExampleSubclass2ViewController' )
			
			expectedObserveConfiguration =
				messageBus:
					baseMessage: [ 'subclass2MessageHandler', 'baseMessageHandler' ]
					subclassMessage: [ 'subclassMessageHandler' ]
			
			expect( viewController.observe ).to.deep.equal( expectedObserveConfiguration )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController
			delete ExampleSubclass2ViewController

			return
		)
		
		specify( 'merges multiple levels of child observe configurations when middle subclass has no observers', ->
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				observe:
					messageBus:
						baseMessage: 'baseMessageHandler'
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
			)
			
			Ext.define( 'ExampleSubclass2ViewController',
				extend: 'ExampleSubclassViewController'
				
				observe:
					messageBus:
						subclass2Message: 'subclass2MessageHandler'
			)
			
			viewController = Ext.create( 'ExampleSubclass2ViewController' )
			
			expectedObserveConfiguration =
				messageBus:
					subclass2Message: [ 'subclass2MessageHandler' ]
					baseMessage: [ 'baseMessageHandler' ]
			
			expect( viewController.observe ).to.deep.equal( expectedObserveConfiguration )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController
			delete ExampleSubclass2ViewController

			return
		)
		
		specify( 'merges multiple levels of subclass observe configurations when the base class has no observers', ->
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus:
						subclassMessage: 'subclassMessageHandler'
			)
			
			Ext.define( 'ExampleSubclass2ViewController',
				extend: 'ExampleSubclassViewController'
				
				observe:
					messageBus:
						subclass2Message: 'subclass2MessageHandler'
			)
			
			viewController = Ext.create( 'ExampleSubclass2ViewController' )
			
			expectedObserveConfiguration =
				messageBus:
					subclass2Message: [ 'subclass2MessageHandler' ]
					subclassMessage: [ 'subclassMessageHandler' ]
			
			expect( viewController.observe ).to.deep.equal( expectedObserveConfiguration )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController
			delete ExampleSubclass2ViewController

			return
		)
		
		specify( 'attaches listeners to observed objects in a ViewController with no subclasses', ->
			eventData = { value1: true, value2: false }

			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
				
				observe:
					messageBus:
						message: 'messageHandler'
				
				messageHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'messageHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )

			viewController = Ext.create( 'ExampleViewController',
				messageBus: messageBus
			)

			expect( hasListener( messageBus, 'message' ) ).to.be.true
			
			messageBus.fireEvent( 'message', eventData )
			
			expect( viewController.messageHandler ).to.be.calledOnce.and.calledWith( eventData).and.calledOn( viewController )

			delete ExampleViewController

			return
		)

		specify( 'attaches listeners to observed objects in a ViewController subclass where the subclass has an observe configuration', ->
			baseEventData = { value1: true, value2: false }
			subclassEventData = { value2: true, value3: false }
			storeEventData = { value5: true, value6: false }
			
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
					myStore: null
				
				observe:
					messageBus:
						baseMessage: 'baseMessageHandler'
					myStore:
						beforesync: 'storeHandler'
				
				baseMessageHandler: ( data ) ->
					return
				
				storeHandler: ( data ) ->
					return
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus:
						subclassMessage: 'subclassMessageHandler'
				
				subclassMessageHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleBaseViewController.prototype, 'baseMessageHandler' )
			sinon.spy( ExampleBaseViewController.prototype, 'storeHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )

			viewController = Ext.create( 'ExampleSubclassViewController',
				messageBus: messageBus
				myStore: store
			)
			
			expect( hasListener( messageBus, 'baseMessage' ) ).to.be.true
			expect( hasListener( messageBus, 'subclassMessage' ) ).to.be.true
			expect( hasListener( store, 'beforesync' ) ).to.be.true

			messageBus.fireEvent( 'baseMessage', baseEventData )
			messageBus.fireEvent( 'subclassMessage', subclassEventData )
			store.fireEvent( 'beforesync', storeEventData )
			
			expect( viewController.baseMessageHandler ).to.be.calledOnce.and.calledWith( baseEventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandler ).to.be.calledOnce.and.calledWith( subclassEventData ).and.calledOn( viewController )
			expect( viewController.storeHandler ).to.be.calledOnce.and.calledWith( storeEventData ).and.calledOn( viewController )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'attaches listeners (with options) to observed objects in a ViewController', ->
			Ext.define( 'ExampleScope', {} )
			expectedScope = Ext.create( 'ExampleScope' )
			baseEventData = { value1: true, value2: false }
			subclassEventData = { value2: true, value3: false }
			storeEventData = { value5: true, value6: false }
			
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
					myStore: null
				
				observe:
					messageBus: [
						event: 'baseMessage'
						fn: 'baseMessageHandler'
						scope: expectedScope
					]
					myStore: [
						event: 'beforesync'
						fn: 'storeHandler'
						scope: expectedScope
					]
				
				baseMessageHandler: ( data ) ->
					return
				
				storeHandler: ( data ) ->
					return
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus: [
						event: 'subclassMessage'
						fn: 'subclassMessageHandler'
						scope: expectedScope
					]
				
				subclassMessageHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleBaseViewController.prototype, 'baseMessageHandler' )
			sinon.spy( ExampleBaseViewController.prototype, 'storeHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )
			
			viewController = Ext.create( 'ExampleSubclassViewController',
				messageBus: messageBus
				myStore: store
			)
			
			expect( hasListener( messageBus, 'baseMessage' ) ).to.be.true
			expect( hasListener( messageBus, 'subclassMessage' ) ).to.be.true
			expect( hasListener( store, 'beforesync' ) ).to.be.true
			
			messageBus.fireEvent( 'baseMessage', baseEventData )
			messageBus.fireEvent( 'subclassMessage', subclassEventData )
			store.fireEvent( 'beforesync', storeEventData )
			
			expect( viewController.baseMessageHandler ).to.be.calledOnce.and.calledWith( baseEventData ).and.calledOn( expectedScope )
			expect( viewController.subclassMessageHandler ).to.be.calledOnce.and.calledWith( subclassEventData ).and.calledOn( expectedScope )
			expect( viewController.storeHandler ).to.be.calledOnce.and.calledWith( storeEventData ).and.calledOn( expectedScope )

			delete ExampleScope
			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'attaches listeners to nested properties of observed objects', ->
			messageEventData = { value1: true, value2: false }
			storeProxyEventData = { value3: true, value4: false }
			deeplyNestedObservableEventData = { value5: true, value6: false }
			
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
					myStore: null
					deeply: null
				
				observe:
					messageBus:
						message: 'messageHandler'
					'myStore.proxy':
						metachange: 'storeProxyHandler'
				
				messageHandler: ( data ) ->
					return
				
				storeProxyHandler: ( data ) ->
					return
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					'deeply.nested.observable':
						exception: "deeplyNestedObservableHandler"
				
				deeplyNestedObservableHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleBaseViewController.prototype, 'messageHandler' )
			sinon.spy( ExampleBaseViewController.prototype, 'storeProxyHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'deeplyNestedObservableHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )
			deeply = Ext.create( 'DeeplyNestedObservable' )
			
			viewController = Ext.create( 'ExampleSubclassViewController',
				messageBus: messageBus
				myStore: store
				deeply: deeply
			)
			
			messageBus.fireEvent( 'message', messageEventData )
			store.getProxy().fireEvent( 'metachange', storeProxyEventData )
			deeply.nested.observable.fireEvent( 'exception', deeplyNestedObservableEventData )
			
			expect( viewController.messageHandler ).to.be.calledOnce.and.calledWith( messageEventData ).and.calledOn( viewController )
			expect( viewController.storeProxyHandler ).to.be.calledOnce.and.calledWith( storeProxyEventData ).and.calledOn( viewController )
			expect( viewController.deeplyNestedObservableHandler ).to.be.calledOnce.and.calledWith( deeplyNestedObservableEventData ).and.calledOn( viewController )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'attaches listeners in the base class and subclass to the same observed object', ->
			eventData = { value1: true, value2: false }
			
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
					myStore: null
				
				observe:
					messageBus:
						message: 'baseMessageHandler'
				
				baseMessageHandler: ( data ) ->
					return
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus:
						message: 'subclassMessageHandler'
				
				subclassMessageHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleBaseViewController.prototype, 'baseMessageHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			
			viewController = Ext.create( 'ExampleSubclassViewController',
				messageBus: messageBus
			)
			
			expect( hasListener( messageBus, 'message' ) ).to.be.true
			
			messageBus.fireEvent( 'message', eventData )
			
			expect( viewController.baseMessageHandler ).to.be.calledOnce.and.calledWith( eventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandler ).to.be.calledOnce.and.calledWith( eventData ).and.calledOn( viewController )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'attaches listeners (with options) in the base class and subclass to the same observed object', ->
			Ext.define( 'ExampleScope', {} )
			expectedScope = Ext.create( 'ExampleScope' )
			eventData = { value1: true, value2: false }
			
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
					store: null
				
				observe:
					messageBus: [
						event: 'message'
						fn: 'baseMessageHandler'
						scope: expectedScope
					]
				
				baseMessageHandler: ( data ) ->
					return
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus: [
						event: 'message'
						fn: 'subclassMessageHandler'
						scope: expectedScope
					]
				
				subclassMessageHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleBaseViewController.prototype, 'baseMessageHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			
			viewController = Ext.create( 'ExampleSubclassViewController',
				messageBus: messageBus
			)
			
			expect( hasListener( messageBus, 'message' ) ).to.be.true
			
			messageBus.fireEvent( 'message', eventData )
			
			expect( viewController.baseMessageHandler ).to.be.calledOnce.and.calledWith( eventData ).and.calledOn( expectedScope )
			expect( viewController.subclassMessageHandler ).to.be.calledOnce.and.calledWith( eventData ).and.calledOn( expectedScope )

			delete ExampleScope
			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'creates observers specified via a variety of the available observe property syntax', ->
			baseEventData = { value1: true, value2: false }
			subclassEventData = { valueA: true, valueB: false }
			subclassEventData2 = { valueC: true, valueD: false }
			storeEventData = { value3: true, value4: false }
			deeplyNestedObservableData = { value5: true, value6: false }
			
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
					myStore: null
					deeply: null
				
				observe:
					messageBus:
						baseMessage: 'baseMessageHandler'
					'myStore.proxy': [
						event: 'metachange'
						fn: 'storeProxyHandler'
					]
				
				baseMessageHandler: ( data ) ->
					return
				
				storeProxyHandler: ( data ) ->
					return
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus: [
						{
							event: 'baseMessage'
							fn: 'subclassMessageHandlerForBaseMessage'
						}
						{
							event: 'subclassMessage'
							fn: 'subclassMessageHandler'
						}
						{
							subclassMessage2: 'subclassMessageHandler2'
						}
					]
					'deeply.nested.observable': [
						event: 'exception'
						fn: 'deeplyNestedObservableHandler'
					]
				
				subclassMessageHandlerForBaseMessage: ( data ) ->
					return
				
				subclassMessageHandler: ( data ) ->
					return
				
				subclassMessageHandler2: ( data ) ->
					return
				
				deeplyNestedObservableHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleBaseViewController.prototype, 'baseMessageHandler' )
			sinon.spy( ExampleBaseViewController.prototype, 'storeProxyHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandlerForBaseMessage' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler2' )
			sinon.spy( ExampleSubclassViewController.prototype, 'deeplyNestedObservableHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )
			deeply = Ext.create( 'DeeplyNestedObservable' )
			
			viewController = Ext.create( 'ExampleSubclassViewController',
				messageBus: messageBus
				myStore: store
				deeply: deeply
			)
			
			expect( hasListener( messageBus, 'baseMessage' ) ).to.be.true
			expect( hasListener( messageBus, 'subclassMessage' ) ).to.be.true
			expect( hasListener( messageBus, 'subclassMessage2' ) ).to.be.true
			expect( hasListener( store.getProxy(), 'metachange' ) ).to.be.true
			expect( hasListener( deeply.nested.observable, 'exception' ) ).to.be.true
			
			messageBus.fireEvent( 'baseMessage', baseEventData )
			messageBus.fireEvent( 'subclassMessage', subclassEventData )
			messageBus.fireEvent( 'subclassMessage2', subclassEventData2 )
			store.getProxy().fireEvent( 'metachange', storeEventData )
			deeply.nested.observable.fireEvent( 'exception', deeplyNestedObservableData )
			
			expect( viewController.baseMessageHandler ).to.be.calledOnce.and.calledWith( baseEventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandlerForBaseMessage ).to.be.calledOnce.and.calledWith( baseEventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandler ).to.be.calledOnce.and.calledWith( subclassEventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandler2 ).to.be.calledOnce.and.calledWith( subclassEventData2 ).and.calledOn( viewController )
			expect( viewController.storeProxyHandler ).to.be.calledOnce.and.calledWith( storeEventData ).and.calledOn( viewController )
			expect( viewController.deeplyNestedObservableHandler ).to.be.calledOnce.and.calledWith( deeplyNestedObservableData ).and.calledOn( viewController )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'creates observers specified via a variety of the available observe property syntax (with event options)', ->
			baseEventData = { value1: true, value2: false }
			subclassEventData = { valueA: true, valueB: false }
			subclassEventData2 = { valueC: true, valueD: false }
			storeEventData = { value3: true, value4: false }
			deeplyNestedObservableEventData = { value5: true, value6: false }
			
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
					myStore: null
					deeply: null
				
				observe:
					messageBus:
						baseMessage: 'baseMessageHandler'
					'myStore.proxy': [
						event: 'metachange'
						fn: 'storeProxyHandler'
						single: true
					]
				
				baseMessageHandler: ( data ) ->
					return
				
				storeProxyHandler: ( data, eventOptions ) ->
					expect( eventOptions.single ).to.be.true
					return
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus: [
						{
							event: 'baseMessage'
							fn: 'subclassMessageHandlerForBaseMessage'
						}
						{
							event: 'subclassMessage'
							fn: 'subclassMessageHandler'
							single: true
						}
						{
							subclassMessage2: 'subclassMessageHandler2'
						}
					]
					'deeply.nested.observable': [
						event: 'exception'
						fn: 'deeplyNestedObservableHandler'
						single: true
					]
				
				subclassMessageHandlerForBaseMessage: ( data ) ->
					return
				
				subclassMessageHandler: ( data, eventOptions ) ->
					expect( eventOptions.single ).to.be.true
					return
				
				subclassMessageHandler2: ( data ) ->
					return
				
				deeplyNestedObservableHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleBaseViewController.prototype, 'baseMessageHandler' )
			sinon.spy( ExampleBaseViewController.prototype, 'storeProxyHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandlerForBaseMessage' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler2' )
			sinon.spy( ExampleSubclassViewController.prototype, 'deeplyNestedObservableHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )
			deeply = Ext.create( 'DeeplyNestedObservable' )
			
			viewController = Ext.create( 'ExampleSubclassViewController',
				messageBus: messageBus
				myStore: store
				deeply: deeply
			)
			
			expect( hasListener( messageBus, 'baseMessage' ) ).to.be.true
			expect( hasListener( messageBus, 'subclassMessage' ) ).to.be.true
			expect( hasListener( messageBus, 'subclassMessage2' ) ).to.be.true
			expect( hasListener( store.getProxy(), 'metachange' ) ).to.be.true
			expect( hasListener( deeply.nested.observable, 'exception' ) ).to.be.true
			
			messageBus.fireEvent( 'baseMessage', baseEventData )
			messageBus.fireEvent( 'subclassMessage', subclassEventData )
			messageBus.fireEvent( 'subclassMessage2', subclassEventData2 )
			store.getProxy().fireEvent( 'metachange', storeEventData )
			deeply.nested.observable.fireEvent( 'exception', deeplyNestedObservableEventData )
			
			# Fire extra events to verify single: true
			messageBus.fireEvent( 'subclassMessage', subclassEventData )
			store.getProxy().fireEvent( 'metachange', storeEventData )
			deeply.nested.observable.fireEvent( 'exception', deeplyNestedObservableEventData )
			
			expect( viewController.baseMessageHandler ).to.be.calledOnce.and.calledWith( baseEventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandlerForBaseMessage ).to.be.calledOnce.and.calledWith( baseEventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandler ).to.be.calledOnce.and.calledWith( subclassEventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandler2 ).to.be.calledOnce.and.calledWith( subclassEventData2 ).and.calledOn( viewController )
			expect( viewController.storeProxyHandler ).to.be.calledOnce.and.calledWith( storeEventData ).and.calledOn( viewController )
			expect( viewController.deeplyNestedObservableHandler ).to.be.calledOnce.and.calledWith( deeplyNestedObservableEventData ).and.calledOn( viewController )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		return
	)

	describe( 'Handles anticipated uses of mixins in view controllers', ->

		delete ExampleComponent
		delete ExampleView

		beforeEach( ->
			Ext.define( 'ExampleComponent',
				extend: 'Ext.Component'
				alias: 'widget.example'

				renderTo: 'componentTestArea'

				fireExampleEvent: ( value ) ->
					@fireEvent( 'exampleevent', @, value )
					return
			)

			Ext.define( 'ExampleView',
				extend: 'Ext.Container'

				renderTo: 'componentTestArea'
				# Ext JS
				items: [
					xtype: 'example'
					itemId: 'example'
				]
				config:
					# Sencha Touch
					items: [
						xtype: 'example'
						itemId: 'example'
					]

				fireExampleEvent: ( value ) ->
					@fireEvent( 'exampleevent', @, value )
					return
			)

			Ext.DomHelper.append( Ext.getBody(), '<div id="componentTestArea" style="visibility: hidden"></div>' )

			return
		)

		afterEach( ->
			# Ensure that injector stub is restored in the event of a spec failure.
			if Deft.Injector.inject.restore
				Deft.Injector.inject.restore()
			Ext.removeNode( Ext.get( 'componentTestArea' ).dom )
			delete ExampleComponent
			delete ExampleView
			return
		)

		specify( 'creates and destroys mixed in classes for view controllers and performs injections using ViewController class\'s Injectable mixin.', ->

			injectStub = sinon.stub( Deft.Injector, 'inject' )

			Ext.define( 'ViewControllerMixin',
				extend: 'Ext.Mixin'
				mixins: [ 'Deft.mixin.Injectable', 'Deft.mixin.Observer' ]
				inject: [ 'identifier2' ]

				#companions:
				#	associatedController2: "AssociatedViewController2"

				constructor: ->
					#expect( injectStub ).to.be.calledWith( @inject, @, arguments, false )
					#expect( @inject ).to.be.eql(
					#	identifier2: 'identifier2'
					#)
					temp = @inject
					debugger
					return @callParent( arguments )

				destroy: ->
					Ext.log( "mixin destroy" )
					@callParent( arguments )
					@removeObservers()
					return true
			)

			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				mixins: [ 'ViewControllerMixin' ]
				inject: [ 'identifier' ]


				constructor: ->
					#expect( injectStub ).to.be.calledWith( @inject, @, arguments, false )
					#expect( @inject ).to.be.eql(
					#	identifier: 'identifier'
					#)
					temp = @inject
					debugger

					return @callParent( arguments )

				destroy: ->
					Ext.log( "ExampleViewController destroy" )
					@callParent( arguments )
					return true
			)



			Ext.define( 'AssociatedViewController2',
				extend: 'Deft.mvc.ViewController'

			)

			#sinon.spy( ViewControllerMixin.prototype, 'destroy' )
			#sinon.spy( ExampleViewController.prototype, 'destroy' )

			view = Ext.create( 'ExampleView' )

			#viewController = Ext.create( 'ExampleViewController',
			#	view: view
			#)
			viewController = Ext.create( 'ExampleViewController' )
			viewController.setView( view )

			expect( viewController.getView() ).to.equal( view )
			#expect( associatedController1.getView() ).to.equal( view )
			#expect( associatedController2.getView() ).to.equal( view )

			viewController.destroy()
			#expect( associatedController1.destroy ).to.be.calledOnce.and.calledOn( associatedController1 )
			#expect( associatedController2.destroy ).to.be.calledOnce.and.calledOn( associatedController2 )

			injectStub.restore()

			delete ExampleViewController
			delete ViewControllerMixin

			return
		)
	)

	describe( 'Destruction and clean-up', ->

		before( ->
			Ext.define( 'ExampleComponent',
				extend: 'Ext.Component'
				alias: 'widget.example'
			)

			Ext.define( 'ExampleView',
				extend: 'Ext.Container'

				renderTo: 'componentTestArea'
				# Ext JS
				items: [
					{
						xtype: 'example'
						itemId: 'example'
					}
				]
				config:
					# Sencha Touch
					items: [
						{
							xtype: 'example'
							itemId: 'example'
						}
					]
			)

			return
		)

		after( ->
			delete ExampleComponent
			delete ExampleView
			return
		)

		beforeEach( ->
			Ext.DomHelper.append( Ext.getBody(), '<div id="componentTestArea" style="visibility: hidden"></div>' )
			return
		)
		
		afterEach( ->
			Ext.removeNode( Ext.get( 'componentTestArea' ).dom )
			return
		)
		
		specify( 'calls destroy() when the associated view is destroyed', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'

				destroy: ->
					return true
			)

			view = Ext.create( 'ExampleView' )
			viewController = Ext.create( 'ExampleViewController' )
			viewController.setView( view )

			sinon.spy( viewController, 'destroy' )

			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()

			expect( isViewDestroyed ).to.be.true
			expect( viewController.destroy ).to.be.calledOnce

			delete ExampleViewController

			return
		)
		
		specify( 'cancels view destruction if the view controller\'s destroy() returns false', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				destroy: ->
					return false
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController' )
			viewController.setView( view )
			
			sinon.spy( viewController, 'destroy' )
			
			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()
			
			expect( viewController.destroy ).to.be.calledOnce
			expect( isViewDestroyed ).to.be.false

			delete ExampleViewController
			
			return
		)

		specify( 'removes listeners from observed objects when the view controller is destroyed', ->
			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'
				
				config:
					store1: null
					store2: null
				
				observe:
					store1:
						beforesync: 'genericHandler'
					'store1.proxy':
						customevent: 'genericHandler'
					store2:
						beforesync: 'genericHandler'
						beforeload: 'genericHandler'
				
				genericHandler: ->
					return
			)
			
			view = Ext.create( 'ExampleView' )
			store1 = Ext.create( 'Ext.data.ArrayStore' )
			store2 = Ext.create( 'Ext.data.ArrayStore' )
			
			expect( hasListener( store1, 'beforesync' ) ).to.be.false
			expect( hasListener( store1.getProxy(), 'customevent' ) ).to.be.false
			expect( hasListener( store2, 'beforeload' ) ).to.be.false

			viewController = Ext.create( 'ExampleClass',
				store1: store1
				store2: store2
			)
			viewController.setView( view )
			
			sinon.spy( viewController, 'removeObservers' )

			expect( hasListener( store1, 'beforesync' ) ).to.be.true
			expect( hasListener( store1.getProxy(), 'customevent' ) ).to.be.true
			expect( hasListener( store2, 'beforeload' ) ).to.be.true
			expect( hasListener( store2, 'beforesync' ) ).to.be.true

			view.destroy()
			
			expect( viewController.removeObservers ).to.be.calledOnce
			
			expect( hasListener( store1, 'beforesync' ) ).to.be.false
			expect( hasListener( store1.getProxy(), 'customevent' ) ).to.be.false
			expect( hasListener( store2, 'beforesync' ) ).to.be.false
			expect( hasListener( store2, 'beforeload' ) ).to.be.false

			delete ExampleClass

			return
		)
	)
	return
)