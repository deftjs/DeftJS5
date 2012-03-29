Ext.define("Deft.ioc.DependencyProvider",{config:{identifier:null,className:null,parameters:null,fn:null,value:null,singleton:!0,eager:!1},constructor:function(a){this.initConfig(a);null!=a.value&&a.value.constructor===Object&&this.setValue(a.value);this.getEager()&&(null!=this.getValue()&&Ext.Error.raise("Error while configuring '"+this.getIdentifier()+"': a 'value' cannot be created eagerly."),this.getSingleton()||Ext.Error.raise("Error while configuring '"+this.getIdentifier()+"': only singletons can be created eagerly."));
this.getSingleton()||null!=this.getValue()&&Ext.Error.raise("Error while configuring '"+this.getIdentifier()+"': a 'value' can only be configured as a singleton.");return this},resolve:function(a){var c;Ext.log("Resolving '"+this.getIdentifier()+"'.");if(null!=this.getValue())return this.getValue();c=null;null!=this.getFn()?(Ext.log("Executing factory function."),c=this.fn(a)):null!=this.getClassName()?(Ext.log("Creating instance of '"+this.getClassName()+"'."),a=null!=this.getParameters()?[this.getClassName()].concat(this.getParameters()):
[this.getClassName()],c=Ext.create.apply(this,a)):Ext.Error.raise("Error while configuring rule for '"+this.getIdentifier()+"': no 'value', 'fn', or 'className' was specified.");this.getSingleton()&&this.setValue(c);return c}});
Ext.define("Deft.ioc.Injector",{alternateClassName:["Deft.Injector"],requires:["Deft.ioc.DependencyProvider"],singleton:!0,constructor:function(){this.providers={};return this},configure:function(a){Ext.log("Configuring injector.");Ext.Object.each(a,function(a,b){var d;Ext.log("Configuring dependency provider for '"+a+"'.");d=Ext.isString(b)?Ext.create("Deft.ioc.DependencyProvider",{identifier:a,className:b}):Ext.create("Deft.ioc.DependencyProvider",Ext.apply({identifier:a},b));this.providers[a]=
d},this);Ext.Object.each(this.providers,function(a,b){b.getEager()&&(Ext.log("Eagerly creating '"+b.getIdentifier()+"'."),b.resolve())},this)},canResolve:function(a){return null!=this.providers[a]},resolve:function(a,c){var b;b=this.providers[a];return null!=b?b.resolve(c):Ext.Error.raise("Error while resolving value to inject: no dependency provider found for '"+a+"'.")},inject:function(a,c){var b,d,e,h;b={};Ext.isString(a)&&(a=[a]);Ext.Object.each(a,function(d,e){var g,f;f=Ext.isArray(a)?e:d;g=
this.resolve(e,c);c.config.hasOwnProperty(f)?(Ext.log("Injecting '"+e+"' into 'config."+f+"'."),b[f]=g):(Ext.log("Injecting '"+e+"' into '"+f+"'."),c[f]=g)},this);if(c.$configInited)for(d in b)h=b[d],e="set"+Ext.String.capitalize(d),c[e].call(c,h);else c.config=Ext.Object.merge({},c.config||{},b);return c}});
Ext.define("Deft.mvc.ViewController",{alternateClassName:["Deft.ViewController"],config:{view:null},constructor:function(a){this.initConfig(a);!this.getView()instanceof Ext.ClassManager.get("Ext.Component")&&Ext.Error.raise("Error constructing ViewController: the 'view' is not an Ext.Component.");this.registeredComponents={};if(this.getView().events.initialize)this.getView().on("initialize",this.onViewInitialize,this,{single:!0});else if(this.getView().rendered)this.init();else this.getView().on("afterrender",
this.onViewInitialize,this,{single:!0});return this},init:function(){},destroy:function(){return!0},onViewInitialize:function(){var a,c,b,d;this.getView().on("beforedestroy",this.onViewBeforeDestroy,this);this.getView().on("destroy",this.onViewDestroy,this,{single:!0});d=this.control;for(b in d)c=d[b],a=this.locateComponent(b,c),c=Ext.isObject(c.listeners)?c.listeners:c,this.registerComponent(b,a,c);this.init()},onViewBeforeDestroy:function(){return this.destroy()?(this.getView().un("beforedestroy",
this.onBeforeDestroy,this),!0):!1},onViewDestroy:function(){for(var a in this.registeredComponents)this.unregisterComponent(a)},getComponent:function(a){var c;return null!=(c=this.registeredComponents[a])?c.component:void 0},registerComponent:function(a,c,b){var d,e;Ext.log("Registering '"+a+"' component.");null!=this.getComponent(a)&&Ext.Error.raise("Error registering component: an existing component already registered as '"+a+"'.");this.registeredComponents[a]={component:c,listeners:b};"view"!==
a&&(e="get"+Ext.String.capitalize(a),this[e]||(this[e]=Ext.Function.pass(this.getComponent,[a],this)));if(Ext.isObject(b))for(d in b)if(e=b[d],Ext.log("Adding '"+d+"' listener to '"+a+"'."),Ext.isFunction(this[e]))c.on(d,this[e],this);else Ext.Error.raise("Error adding '"+d+"' listener: the specified handler '"+e+"' is not a Function or does not exist.")},unregisterComponent:function(a){var c,b,d,e;Ext.log("Unregistering '"+a+"' component.");null==this.getComponent(a)&&Ext.Error.raise("Error unregistering component: no component is registered as '"+
a+"'.");d=this.registeredComponents[a];c=d.component;e=d.listeners;if(Ext.isObject(e))for(b in e)d=e[b],Ext.log("Removing '"+b+"' listener from '"+a+"'."),Ext.isFunction(this[d])?c.un(b,this[d],this):Ext.Error.raise("Error removing '"+b+"' listener: the specified handler '"+d+"' is not a Function or does not exist.");"view"!==a&&(c="get"+Ext.String.capitalize(a),this[c]=null);this.registeredComponents[a]=null},locateComponent:function(a,c){var b;b=this.getView();if("view"===a)return b;Ext.isString(c)?
(b=b.query(c),0===b.length&&Ext.Error.raise("Error locating component: no component found matching '"+c+"'."),1<b.length&&Ext.Error.raise("Error locating component: multiple components found matching '"+c+"'.")):Ext.isString(c.selector)?(b=b.query(c.selector),0===b.length&&Ext.Error.raise("Error locating component: no component found matching '"+c.selector+"'."),1<b.length&&Ext.Error.raise("Error locating component: multiple components found matching '"+c.selector+"'.")):(b=b.query("#"+a),0===b.length&&
Ext.Error.raise("Error locating component: no component found with an itemId of '"+a+"'."),1<b.length&&Ext.Error.raise("Error locating component: multiple components found with an itemId of '"+a+"'."));return b[0]}});Ext.define("Deft.mixin.Injectable",{requires:["Deft.ioc.Injector"],onClassMixedIn:function(a){a.prototype.constructor=Ext.Function.createInterceptor(a.prototype.constructor,function(){return Deft.Injector.inject(this.inject,this)})}});
Ext.define("Deft.mixin.Controllable",{requires:["Deft.mvc.ViewController"],onClassMixedIn:function(a){a.prototype.constructor=Ext.Function.createSequence(a.prototype.constructor,function(){var a,b,d,e;null==this.controller&&Ext.Error.raise("Error initializing Controllable instance: `controller` is null.");b=Ext.isArray(this.controller)?this.controller:[this.controller];d=0;for(e=b.length;d<e;d++)a=b[d],Ext.create(a,{view:this})})}});
