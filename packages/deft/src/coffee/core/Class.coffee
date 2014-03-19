###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* A collection of useful static methods for interacting with (and normalizing differences between) the Sencha Touch and Ext JS class systems.
* @private
###
Ext.define( 'Deft.core.Class',
	alternateClassName: [ 'Deft.Class' ]

	statics:

		###*
		* Determines whether the passed Class reference is or extends the specified Class (by name).
		*
		* @return {Boolean} A Boolean indicating whether the specified Class reference is or extends the specified Class (by name)
		###
		extendsClass: ( targetClass, className ) ->
			try
				return true if Ext.getClassName( targetClass ) is className
				if targetClass?.superclass
					if Ext.getClassName( targetClass.superclass ) is className
						return true
					else
						return Deft.Class.extendsClass( Ext.getClass( targetClass.superclass ), className )
				else return false
			catch error
				return false
)
