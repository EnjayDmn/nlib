/*
 * $Id: nlib.js,v 1.22 2014-03-10 20:30:57 nils-1327 Exp $ 
 */

var NLIB_DEBUG       = 0x0001;
var NLIB_INFO        = 0x0002;
var NLIB_ERROR       = 0x0004;
var NLIB_JSON        = 0x0008;

var NLIBDEBUG = NLIB_DEBUG | NLIB_INFO | NLIB_ERROR | NLIB_JSON;

NlibObject.prototype = new Object;
NlibObject.prototype.constructor = NlibObject;
function NlibObject(){
	this.xmlhttp = null;
  
	if (window.XMLHttpRequest) {
		this.xmlhttp = new window.XMLHttpRequest();
	}
	else{
		try{
			this.xmlhttp = new ActiveXObject("Microsoft.XMLHTTP.3.0");
		}
		catch(ex){
			this.debug(NLIB_CONSTRUCT,"new","Exception: "+ex);
		}
	}

	this.addReadyStateListener(this);
} // NlibObject

NlibObject.prototype.debug = function(level,meth,msg){
	var l = "";
	if(!console){return;}
	
	if((NLIBDEBUG & level) == NLIB_DEBUG )
		l = "[NLIB_DEBUG] ";

	else if((NLIBDEBUG & level) == NLIB_INFO )
		l = "[NLIB_INFO]  ";

	else if((NLIBDEBUG & level) == NLIB_ERROR )
		l = "[NLIB_ERROR] ";
	
	else if((NLIBDEBUG & level) == NLIB_JSON )
		l = "[NLIB_JSON] ";

	if(l != "")
	{
		if(meth && msg){ console.log(l+": "+this.constructor.name+"::"+meth+": "+msg); }
		else if(meth){ console.log(l+": "+this.constructor.name+"::"+meth); }
		else{ console.log(l+": "+this.constructor.name); }
	}


}

NlibObject.prototype.addReadyStateListener = function(obj){
		this.debug(NLIB_INFO,"addReadyStateListener");

		if(obj.xmlhttp)
		{
			if (!obj.xmlhttp.addEventListener)
			{
				obj.xmlhttp.onreadystatechange =  function(){
					if(obj.xmlhttp.readyState == 4 && obj.xmlhttp.status == 200 ){ obj.parseResponse(obj.xmlhttp.responseText); }
				};
			}
			else{
				obj.xmlhttp.addEventListener("readystatechange",function(){
					if(obj.xmlhttp.readyState == 4 && obj.xmlhttp.status == 200){ obj.parseResponse(obj.xmlhttp.responseText); }
				});
			}
		}
	}

/*
 * This method is for debugging JSON data.
 */
NlibObject.prototype.debugJSON = function(data){
	return JSON.stringify(data);
}


NlibObject.prototype.encodeRequest = function(data){
		this.debug(NLIB_INFO,"encodeRequest");
		$.base64.utf8encode = true;
		//var json = JSON;
		if(data)
		{
			//this.debug(NLIB_DEBUG,"encodeRequest","Returning "+$.base64('encode',json.stringify(data)));

			seen = []

			json = JSON.stringify(data, function(key, val) {
				if (typeof val == "object") {
					if (seen.indexOf(val) >= 0)
						return;
					seen.push(val)
				}
				return val;
			});

			//return $.base64('encode',JSON.stringify(data));
			return $.base64('encode',json);
		}
		else	
		{
			//this.debug(NLIB_DEBUG,"encodeRequest","Returning "+$.base64('encode',json.stringify(this.data)));
			return $.base64('encode',JSON.stringify(this.data));
		}
	}


NlibObject.prototype.sendRequest = function(req,val){
	this.debug(NLIB_INFO,"sendRequest");
	if(this.xmlhttp){
		var params = null;
		if(val)
			params = req+"="+val;
		//this.xmlhttp.open("GET", "%%%MAKEFILE_CGIBIN%%%?"+req+"="+val, true);
		
		this.xmlhttp.open("POST", "%%%MAKEFILE_CGIBIN%%%", true);
		this.xmlhttp.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
//		}
//		else
//			this.xmlhttp.open("GET", "%%%MAKEFILE_CGIBIN%%%?", true);
		this.xmlhttp.send(params);
	}

}
	
NlibObject.prototype.parseResponse = function(resp){
	this.debug(NLIB_INFO,"parseResponse");
};



/*
 * A common widget class. Inherit from this and override parseResponse
 * to handle the server response accordingly.
 */
NlibWidget.prototype = new NlibObject;	
NlibWidget.prototype.constructor = NlibWidget;
function NlibWidget(widgetName,app,data){
	this.debug(NLIB_INFO,"new");

	NlibObject.call(this);

	this.widgetName = widgetName;
	this.app = app;
	this.id_target = "#content"+this.widgetName; // id_target;
	this.id_widget = "widget"+this.widgetName; // id_widget;
	this.src = new String("%%%MAKEFILE_WIDGET_SOURCE%%%/widget"+this.widgetName+".htm");
	this.data = data;
	this.template = null;
}

NlibWidget.prototype.update = function(){
	this.debug(NLIB_INFO,"update");
	var data = new Object();
	data.widgetName = this.widgetName;
	this.sendRequest("updateWidget",this.encodeRequest(data));
}

NlibWidget.prototype.updateModel = function(resp){
	this.debug(NLIB_INFO,"updateModel");
	//this.debug(NLIB_JSON,"updateModel","DATA BEFORE: "+this.debugJSON(this.data));
	var data = $.parseJSON(resp); // store model
	$.extend(this.data,data)
	//this.debug(NLIB_JSON,"updateModel","DATA AFTER: "+this.debugJSON(this.data));
}

NlibWidget.prototype.updateView = function(resp){
	this.debug(NLIB_INFO,"updateView");
	if(!this.template)
		this.loadTemplate();
	this.render();
}

NlibWidget.prototype.refreshData = function(data){
  this.debug(NLIB_INFO,'refreshData');
  this.data = undefined;
  this.data = data;
  // TODO: Overload this is subclass, for example like this: (or whatever
	//       follow-up your refresh request is...)
	//this.sendRequest(this.data.followUp[0],this.encodeRequest(new Object));
}



NlibWidget.prototype.loadTemplate = function(data){
	this.debug(NLIB_INFO,"loadTemplate");
	this.template = new NlibTemplate(this.id_widget,this.src);
}

NlibWidget.prototype.render = function(data){
	this.debug(NLIB_INFO,"render");
		if(data)
		{
			this.template.render(this.id_target,data);
		}
		else
		{
			this.template.render(this.id_target,this.data);
		}
	}

NlibWidget.prototype.go = function(obj){
	this.debug(NLIB_INFO,"go");
	// TODO: Overwrite this method in subclass
	this.loadTemplate();
	this.render();
}

NlibWidget.prototype.requestOkHandler = function(obj){
	this.debug(NLIB_INFO,"requestOkHandler");
	// TODO: Overwrite this method in subclass
}

NlibWidget.prototype.requestFailedHandler = function(obj){
	this.debug(NLIB_INFO,"requestFailedHandler");
	// TODO: Overwrite this method in subclass
}

NlibWidget.prototype.updateView = function(obj){
	this.debug(NLIB_INFO,"updateView");
	if(!this.template)
		this.loadTemplate();
	this.render();
}

NlibWidget.prototype.rebind = function(obj){
	this.debug(NLIB_INFO,"rebind");
}



NlibWidget.prototype.parseResponse = function(resp){
	this.debug(NLIB_INFO,"parseResponse");
	
	//this.updateModel(resp);	
/*
	this._json = $.parseJSON(resp);
	this._status = this._json.status;
	this._running = this._json.running;

	this.debug(NLIB_DEBUG,"parseResponse","Y Response status: "+this._json.status);
	if(this._json.status == "OK")
		this.requestOkHandler();
	else
		this.requestFailedHandler();
*/

  this._json;
  this._status;
  this._running;
  this._message;

    this.debug(NLIB_DEBUG,"parseResponse","HIER");

  try{
    this._json = $.parseJSON(resp);
    this._status = this._json.status;
    this._running = this._json.running;
    this._message = this._json.message;
  } catch (e){
    this._status = "ERROR";
    this._running = 0;
    this.debug(NLIB_DEBUG,"parseResponse","Y Response status: "+this._status+", "+e.message);
    location.href = "%%%MAKEFILE_CGIBIN%%%";
  }

  if(this._status == "OK")
    this.requestOkHandler(this);
  else
    this.requestFailedHandler(this);


};

NlibWidget.prototype.sendRequest = function(req,val){
	this.debug(NLIB_INFO,"sendRequest");
	if(this.xmlhttp){
		var params = null;
		if(val)
			params = req+"="+val;
			//this.xmlhttp.open("GET", "%%%MAKEFILE_CGIBIN%%%?"+req+"="+val, true);
		this.xmlhttp.open("POST", "%%%MAKEFILE_CGIBIN%%%", true);
		this.xmlhttp.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
//		else
//			this.xmlhttp.open("GET", "%%%MAKEFILE_CGIBIN%%%?", true);
		this.xmlhttp.send(params);
	}
}

	

/*
 * A Template class
 */
NlibTemplate.prototype = new NlibObject;
NlibTemplate.prototype.constructor = NlibTemplate;
function NlibTemplate(id_template,src){
	NlibObject.call(this);
	this.src = src || "";
	this.tpl = "";
	this.id_template = id_template;
	this.loadTpl(this);
}

NlibTemplate.prototype.loadTpl = function(obj){
	this.debug(NLIB_INFO,"loadTpl");
		$.ajax({url:this.src,async:false}).done(function(tpldata){obj.tpl = tpldata;});
		//alert("tpl: "+obj.tpl);
	}

NlibTemplate.prototype.render = function(id_target,data){
	this.debug(NLIB_INFO,"render");
	//this.debug(NLIB_DEBUG,"render",this.tpl+", "+this.id_template+", "+data.widgetName);
		if(data){
			$(id_target).html(this.tpl);
			Tempo.prepare(this.id_template).render(data);	
		}
		else
		{
			this.debug(NLIB_ERROR,"render","data is undefined, required template not loaded, maybe the wrong main template?");
		}
}




NlibWidgetLogin.prototype = new NlibWidget;
NlibWidgetLogin.prototype.constructor = NlibWidgetLogin;
function NlibWidgetLogin(app,data){
	this.debug(NLIB_INFO,"new");
	this.widgetName = "Login";
	NlibWidget.call(this,this.widgetName,app,data);
}

NlibWidgetLogin.prototype.go = function(obj){
	this.debug(NLIB_INFO,"go");
	
		this.loadTemplate();
		this.render();
		
		// TODO: Overwrite this method in subclass
		$("#blogin").click(function(){
			var data = new Object();
			data.username = $("#username").val();
			data.password = $("#password").val();
			this.debug(NLIB_DEBUG,"go",obj.data.followUp[0]);
			obj.sendRequest(obj.data.followUp[0],obj.encodeRequest(data))
		});
		$("#blogout").click(function(){
			var data = new Object();
			data.username = $("#username").val();
			data.password = $("#password").val();
			obj.sendRequest(obj.data.followUp[0],obj.encodeRequest(data))
		});

	}

NlibWidgetLogin.prototype.requestOkHandler = function(obj){
	this.debug(NLIB_INFO,"requestOkHandler");
	// TODO: Overwrite this method in subclass
}

NlibWidgetLogin.prototype.requestFailedHandler = function(obj){
	this.debug(NLIB_INFO,"requestFailedHandler");
}


NlibApplication.prototype = new NlibObject;
NlibApplication.prototype.constructor = NlibApplication;
function NlibApplication(){
	this.debug(NLIB_INFO,"new");
	this._followUp = $.parseJSON($(json).html());
	this._json; //= $.parseJSON($(json).html());
	this._status = "ERROR";
	this._running = 0;
	this._widgets = new Array();


	NlibObject.call(this);
}

NlibApplication.prototype.updateAllWidgets = function(){
	this.debug(NLIB_INFO,"updateAllWidgets");
	var data = new Object();
	this.sendRequest(this._followUp.followUp[0],this.encodeRequest(data));
}


NlibApplication.prototype.run = function(){
	this.debug(NLIB_INFO,"run");
	//this.initWidgets();
	this.updateAllWidgets();
	
}

NlibApplication.prototype.isRunning = function(){
	this.debug(NLIB_INFO,"isRunning");
	return this._running;
}


NlibApplication.prototype.requestOkHandler = function(obj){
	this.debug(NLIB_INFO,"requestOkHandler");

	for(var i = 0; i<this._json.widgets.length;i++){
		var curWidget = this._json.widgets[i];
		this.debug(NLIB_DEBUG,"requestOkHandler","curWidget: "+ curWidget.widgetName);
		// dispatch widget by name
		// NEU:
		if(curWidget.widgetName == "Login"){
			if(this._widgets.Login){
				this.debug(NLIB_DEBUG,"requestOkHandler","curWidget: "+ curWidget.widgetName+" is already defined.");
			}
			else{
				this.debug(NLIB_DEBUG,"requestOkHandler","curWidget: "+ curWidget.widgetName+" is undefined. Creating new instance.");
				this._widgets.Login = new NlibWidgetLogin(this,curWidget);
				this._widgets.Login.go(this._widgets.Login);
			}
		}

		/* // ALT:
		if(curWidget.widgetName == "Login"){
			var w = new NlibWidgetLogin(this,curWidget);
			this._widgets.push(w);
			w.go(w);
		}
		*/
	}
}

NlibApplication.prototype.requestFailedHandler = function(obj){
	this.debug(NLIB_INFO,"requestFailedHandler");
}


NlibApplication.prototype.parseResponse = function(resp){
	this.debug(NLIB_INFO,"parseResponse");
	//this.followUp = this._json.followUp;
	this._json = $.parseJSON(resp);
	this._status = this._json.status;
	this._running = this._json.running;

	this.debug(NLIB_DEBUG,"parseResponse","Response status: "+this._json.status);
	if(this._json.status == "OK")
		this.requestOkHandler(this);
	else
		this.requestFailedHandler(this);
};




