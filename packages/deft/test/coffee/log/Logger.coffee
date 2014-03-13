###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

describe( 'Deft.log.Logger', ->

	describe( 'log()', ->


		describe( 'logs a message with the specified priority', ->
			logFunction = null

			checkCall = ( message, priority ) ->
				expect( logFunction ).to.be.calledOnce.and.calledWith( message, priority )

			beforeEach( ->
				logFunction = sinon.stub( Ext.Logger, 'log' )
				return
			)

			afterEach( ->
				logFunction.restore()
				return
			)

			specify( 'no priority specified', ->
				Deft.Logger.log( 'message', 'info' )

				checkCall( 'message', 'info' )
				return
			)

			specify( 'verbose', ->
				Deft.Logger.log( 'message', 'verbose' )

				checkCall( 'message', 'info' )
				return
			)

			specify( 'deprecate', ->
				Deft.Logger.log( 'message', 'deprecate' )

				checkCall( 'message', 'warn' )
				return
			)

			specify( 'warn', ->
				Deft.Logger.log( 'message', 'warn' )

				checkCall( 'message', 'warn' )
				return
			)

			specify( 'error', ->
				Deft.Logger.log( 'message', 'error' )

				checkCall( 'message', 'error' )
				return
			)

			return
		)

	)

	describe( 'verbose()', ->
		logFunction = null

		beforeEach( ->
			logFunction = sinon.stub( Deft.Logger, 'log' )
		)

		afterEach( ->
			logFunction.restore()
		)

		specify( 'calls log() with specified message with verbose priority', ->
			Deft.Logger.verbose( 'message' )

			expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'verbose' )
			return
		)

		return
	)

	describe( 'info()', ->
		logFunction = null

		beforeEach( ->
			logFunction = sinon.stub( Deft.Logger, 'log' )
		)

		afterEach( ->
			logFunction.restore()
		)

		specify( 'calls log() with specified message with info priority', ->
			Deft.Logger.info( 'message' )

			expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'info' )
			return
		)

		return
	)

	describe( 'deprecate()', ->
		logFunction = null

		beforeEach( ->
			logFunction = sinon.stub( Deft.Logger, 'log' )
		)

		afterEach( ->
			logFunction.restore()
		)

		specify( 'calls log() with specified message with deprecate priority', ->
			Deft.Logger.deprecate( 'message' )

			expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'deprecate' )
			return
		)

		return
	)

	describe( 'warn()', ->
		logFunction = null

		beforeEach( ->
			logFunction = sinon.stub( Deft.Logger, 'log' )
		)

		afterEach( ->
			logFunction.restore()
		)

		specify( 'calls log() with specified message with warn priority', ->
			Deft.Logger.warn( 'message' )

			expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'warn' )
			return
		)

		return
	)

	describe( 'error()', ->
		logFunction = null

		beforeEach( ->
			logFunction = sinon.stub( Deft.Logger, 'log' )
		)

		afterEach( ->
			logFunction.restore()
		)

		specify( 'calls log() with specified message with error priority', ->
			Deft.Logger.error( 'message' )

			expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'error' )
			return
		)

		return
	)

	return
)
