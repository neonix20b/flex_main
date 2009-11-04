import com.*;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.text.StyleSheet;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.IFlexDisplayObject;
import mx.events.CloseEvent;
import mx.managers.BrowserManager;
import mx.managers.IBrowserManager;
import mx.managers.PopUpManager;
import mx.utils.URLUtil;

[Bindable]private var myCSS:StyleSheet=new StyleSheet();
private var myTimer:Timer=new Timer(60000, 60);
private var myTimerStatus:Boolean=true;
private var plus5:Number=5;
private var adeptc:adept=null;
public var oldpass:String = new String;
private var KEY:String = "HjRUPxRjRUPxRdVDYFdVDFS0HjRUPxRdVDYF6PkFBK3YlXjc"; 


[Bindable]public var userinfo:XML = new XML;
[Bindable]public var iam:String = new String('0');
[Bindable]private var quotas:XMLList = new XMLList;
[Bindable]private var deattbool:Number = new Number(1);
[Bindable]private var deattboolb:Boolean = new Boolean(true);
[Bindable]private var bfpassword:String = new String('11');
[Bindable]private var bmpassword:String = new String('11');

[Bindable]private var deattlabel:String = new String("Присоединить");
[Bindable]public var balance:String = new String;
[Bindable]private var domain:String = new String;
//[Bindable]private var cur_tagline:String = new String;
[Bindable]public var rebuildlabel:String = new String("Пересоздать");
[Bindable]public var rebuildbool:Boolean = new Boolean(true);
[Bindable]private var infoXML:XML = new XML;
[Bindable]private var stats:XMLList = new XMLList;

[Bindable]private var adepts_height:Number = new Number(15);
[Bindable]private var sites:XMLList = new XMLList;
[Bindable]private var true_sites:XMLList = new XMLList;

[Bindable]private var wtfs:ArrayCollection = new ArrayCollection(
                [ {label:rebuildlabel, data:'0'}, 
                  {label:"Сайт", data:'joomla'}, 
                  {label:"Форум", data:'smf'}, 
                  {label:"Блог", data:'wordpress'},
                  {label:"Пусто", data:'none'}]);


public function init():void{
	myCSS.setStyle("a", {color: '#FF8400', fontWeight: 'bold'});
	Alert.yesLabel = "Угу";
	Alert.noLabel = "Неа";  
	iam='0';
	load_param();
	whoiam();
	
	//load_stats();
}

public function whoiam(adeptb:Boolean=true):void{
	var loader:URLLoader = new URLLoader();
	var request:URLRequest = new URLRequest("http://oxnull.net/account/whoiam.xml");
	var variables:URLVariables = new URLVariables();
	variables.p = new String('p');
	if(iam!='0')variables.user_id=iam;
	request.method = URLRequestMethod.POST;
	request.data = variables;
	loader.load(request);
	loader.addEventListener(Event.COMPLETE, onCompletewh);

	function onCompletewh(event:Event):void {
		var loader:URLLoader = URLLoader(event.target);
		if(loader.data != "error"){
			userinfo=XML(loader.data);
			if(userinfo.status.toString()=='0'){
				rebuildlabel="Создается";
				rebuildbool=false;
			}
			if(userinfo.status.toString()=='1'){
				rebuildlabel="Пересоздается";
				rebuildbool=false;
			}
			enterwin.userinfo=userinfo;
			bfpassword = CRYPTER.decode(userinfo.child('ftppass').toString());
			bmpassword = CRYPTER.decode(userinfo.child('mysqlpass').toString());
			loadquotas();
			load_service();
			enterok(adeptb);
		}
	}			
}

private function save_tags(user_id:String,tags:String):void{
	var variables:URLVariables = new URLVariables();
	variables.user_id = new String(user_id);
	variables.tags = new String(tags);
	link_to_remote("http://oxnull.net/flex/tag_control/set_tags",variables);
	tags_ok.visible=false;
	myTimer.start();
}
private function load_stats():void{
	if(stats.length()>1)return void;
	var myDate1:Date = new Date();
	var myDate2:Date = new Date();
	myDate2.time -= 1000*10*24*60*60; 
	Security.loadPolicyFile("http://stats.oxnull.net/crossdomain.xml");
	link_to_remote("http://stats.oxnull.net/cgi-bin/xml.py?timestamp2="+1000*int(myDate1.time/1000000)+"&xml=for_period&timestamp1="+1000*int(myDate2.time/1000000)+'#');
}
public function load_service():void{
	if(service_list){
		var clientsXML:XML;
		var loader:URLLoader=new URLLoader();
		var request:URLRequest=new URLRequest("http://oxnull.net/flex/service_list.xml");
		var variables:URLVariables = new URLVariables();
		variables.p = new String('p');
		if(iam!='0')variables.user_id=iam;
		request.method = URLRequestMethod.POST;
		request.data = variables;
		loader.load(request);
		loader.addEventListener(Event.COMPLETE, onComplete);
	}
	function onComplete(event:Event):void{
		var loader:URLLoader=URLLoader(event.target);
		clientsXML=new XML(loader.data);
		balance=clientsXML.balance.toString();
		service_list.removeAllChildren();
		for each(var xml:XML in clientsXML.child('list').children())
		{
			var oneserv:service = new service();
			oneserv.sname=xml.name.toString();
			oneserv.sprice=Number(xml.coast);
			oneserv.ssize=Number(xml.stat);
			oneserv.sid=xml.id.toString();
			if(xml.stat.toString()=='0')oneserv.sstate='Выкл';
			else oneserv.sstate='Работает';
			oneserv.sdescription=xml.description.toString();
			oneserv.width=465;
			service_list.addChild(oneserv);
				//Alert.show(xml.name.toString());
		}
	}
}

public function closeenter(event:Event):void{
	//enterWindow.visible=false;
	//bannerwindow.height = 0;
	//PopUpManager.removePopUp(enterWindow);
	var dBox:IFlexDisplayObject=event.target as IFlexDisplayObject;
	PopUpManager.removePopUp(dBox);
}

public function showenter():void{
	if(enterbutton.text=="Вход"){
		var dBox:IFlexDisplayObject=PopUpManager.createPopUp(this, enterwin, true);
		PopUpManager.centerPopUp(dBox);
		dBox.addEventListener("close", closeenter);
			//userinfo=(dBox as enterwin).userinfo;
	}
	else{
		userinfo=null;
		enterwin.userinfo=null;
		enterok();
		iam='0';
		link_to_remote("http://oxnull.net/account/logout.xml");
		Alert.show('Выход выполнен',"Выход");
	}
}

private function load_param():void{
	var bm:IBrowserManager;
	bm = BrowserManager.getInstance();                
	bm.init();      
	var o:Object = URLUtil.stringToObject(bm.fragment);                
	if(o.pay=='ok'){
		bm.setFragment("");
		Alert.show('Платеж принят','oxnull.net');
	}
	if(o.hello!=null){
		var dBox:IFlexDisplayObject=PopUpManager.createPopUp(this, register_win, true);
		(dBox as register_win).invite=o.hello;
		(dBox as register_win).minit();
		bm.setFragment("");
		PopUpManager.centerPopUp(dBox);
		dBox.addEventListener("close", closeenter);
	}
}

public function show_video(e:Event):void{
	var dBox:IFlexDisplayObject=PopUpManager.createPopUp(this, video_win, true);
	PopUpManager.centerPopUp(dBox);
	if(e.target.text.substr(0,3)=='Joo')(dBox as video_win).video_src="http://video.oxnull.net/movies/joomla_start.flv";
	if(e.target.text.substr(0,3)=='Wor')(dBox as video_win).video_src="http://video.oxnull.net/movies/wordpress_start.flv";
	if(e.target.text.substr(0,3)=='SMF')(dBox as video_win).video_src="http://video.oxnull.net/movies/forum_start.flv";
	if(e.target.text.substr(0,3)=='Ron')(dBox as video_win).video_src="http://video.oxnull.net/movies/ronnie_joomla_install.flv";
	(dBox as video_win).title=e.target.text;
	dBox.addEventListener("close", closeenter);
}

private function taskdo(task:String):void{
	var variables:URLVariables = new URLVariables();
	if(task=='rebuild'){
		if(rebuildbu.selectedItem.data==0)return;	
		Alert.show("  Точно пересоздать как "+rebuildbu.selectedLabel+"?\n   Все данные будут потеряны","Управление",Alert.YES | Alert.NO,this, rebuild);
		function rebuild(eventObj:CloseEvent):void {
			if (eventObj.detail==Alert.YES){
				rebuildbool=false;
				deattboolb=false;
				rebuildlabel="Пересоздается";
				variables.task = new String(task);
				variables.wtf = new String(rebuildbu.selectedItem.data.toString());
				link_to_remote("http://oxnull.net/flex/dotask.xml",variables);
			}
			else{
				rebuildbu.selectedIndex=0;
			}
		}
	}
	if(task=='deattach'&&deattlabel=="Отсоединить"){
		Alert.show("Точно отсоединить домен?","Управление",Alert.YES | Alert.NO,this, deattact);
		function deattact(eventObj:CloseEvent):void {
			if (eventObj.detail==Alert.YES){
				deattboolb=false;
				variables.task = new String(task);
				link_to_remote("http://oxnull.net/flex/dotask.xml",variables);
				deattboolb=true;
				domain='';
				deattbool=1;
				deattlabel="Присоединить";
					//Alert.show('Отсоединили'); 
			}
		}
	}
	if(task=='deattach'&&deattlabel=="Присоединить"){
		var pattern:RegExp = /\A[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]{1,3})?\.[a-zA-Z]{2,4}\Z/g; 
		pattern.ignoreCase;
		if(pattern.test(new_domain.text)){
			variables.domain = new String(new_domain.text);
			variables.task = new String('attach');
			link_to_remote("http://oxnull.net/flex/dotask.xml",variables);
			domain=new_domain.text;
			deattbool=0;
			deattlabel="Отсоединить";
				//Alert.show("подходит");
		}
		else Alert.show('Это не похоже на домен второго уровня','Явка провалена'); 
			//Alert.show('>>>Домен присоединен'); 
	}
	if(task=='newinvite'){
		variables.task = new String(task);
		link_to_remote("http://oxnull.net/flex/dotask.xml",variables);
			//Alert.show("Приглашение создано >>>>и скопировано в память компутера. Осталось его вставить и nотправить","Буфер обмена");
	}
	if(task=='delinvite'){
		Alert.show('>>>Приглашение удалено'); 
	}
}

private function sortXMLList(list:XMLList, fieldName:Object, options:Object = null):XMLList{
     var arr:Array = new Array();
     var ch:XML;
     for each(ch in list)
     {
           arr.push(ch);
     }
     var resultArr:Array = fieldName==null ?
           options==null ? arr.sort() :arr.sort(options)
           : arr.sortOn(fieldName, options);
    arr.reverse();
     var result:XMLList = new XMLList();
     for(var i:int=0; i<resultArr.length; i++)
     {
           result += resultArr[i];
     }
     return result;
}

public function link_to_remote(url:String,variables:URLVariables=null,func:Function=null):void{
	var loader:URLLoader=new URLLoader();
	var request:URLRequest=new URLRequest(url);
	if(variables==null){
		var variables:URLVariables = new URLVariables();
		variables.p = new String('p');
	}
	if(iam!='0')variables.user_id=iam;
	request.data = variables;
	if(url.substr(0,38)!="http://stats.oxnull.net/cgi-bin/xml.py")
			request.method = URLRequestMethod.POST;
	loader.load(request);
	loader.addEventListener(Event.COMPLETE, onComplete);

	function onComplete(event:Event):void{
		var loader:URLLoader=URLLoader(event.target);
		if(loader.data.substr(0,17)=='oxnull.net/#hello')
			copyer("http://"+loader.data,"Приглашение создано и скопировано в память компутера. Осталось его вставить и отправить");

		if(rebuildbu)rebuildbu.enabled=true;
		if(deattbu)deattbu.enabled=true;
		loadquotas();
		if(url=="http://oxnull.net/flex/service_change.xml")balance=loader.data;
		if(url.substr(0,38)=="http://stats.oxnull.net/cgi-bin/xml.py"){
				stats = (new XML(loader.data)).children();
				stats = sortXMLList(stats,'uq',Array.NUMERIC);
				var num:Number=new Number(0);
				 for each(var item:XML in stats) {
	                (item as XML).appendChild("<npp>"+num+"</npp>");
	                if(num==0){
	                	(item as XML).npp='';
	                	(item as XML).domain='Всего';
	                } 
	                //if(num > 10) delete (stats as XML).item[num] ;
	                num++;
	            }
  			}
  		if(url=="http://oxnull.net/flex/tag_control/set_tags" && catalog)catalog.load_tag_list();
  		if(url=="http://oxnull.net/flex/password_change/" && loader.data=='error')
				Alert.show("Старый пароль не верен! Будет выполнен принудительный выход.",'Смена пароля');
		if(url=="http://oxnull.net/account/signup.xml")whoiam();
		if(func != null)func(loader.data.toString());
	}
}

private function copyer(text:String,wtf:String):void{
	Alert.show(wtf,"Буфер обмена",Alert.OK, null,copyme);
	function copyme(eventObj:CloseEvent):void {
		System.setClipboard(text);
	}
}

public function enterok(adeptb:Boolean=true):void{
	if(enterwin.userinfo != "" && enterwin.userinfo != null){
		//авторизован 
		userinfo=enterwin.userinfo;
		if(userinfo.right.toString()!='user'&&adeptb){
			adeptc = new adept;
			adeptc.label="Адепт"
			tab_nav.addChild(adeptc);
		}
		enterbutton.text="Выход"
		reg_id.visible=false;
		loadquotas();
		if(userinfo.domain.toString()!=''){
			deattbool=0;
			domain=userinfo.domain.toString()
			deattlabel="Отсоединить";
		}
		else {
			deattbool=1;
			deattlabel="Присоединить";
		}
		mysite.enabled=true;
		myservices.enabled=true;
		rebuilder();
		load_service();
	}
	else{
		mysite.enabled=false;
		myservices.enabled=false;
		enterbutton.text="Вход"
		reg_id.visible=true;
		if(adeptc){
			tab_nav.removeChild(adeptc);
			adeptc=null;
		}
		
			//не авторизован 
	}

}

private function get_user(wtf:String):String{
	return userinfo.child(wtf).toString();
}
private function timerHandler(event:TimerEvent):void{
	loadquotas();
}

public function gotourl(url:String):void{
	if(url==null||url==""||url=="Всего")return void;
	if(url.substr(0,18)!='oxnull.net/#hello='){
		var request:URLRequest=new URLRequest("http://" + url);
		navigateToURL(request, "_blank");
	}
	else{
		System.setClipboard("http://"+url);
		Alert.show("Приглашение скопировано в память компутера. Осталось его вставить и\nотправить","Буфер обмена");
	}

}

private function clear_pass(event:Event):void{
	if(event.target.text=="123456ss")event.target.text="";
}

private function rebuilder():void{
	//if(invitesgrid){
	//Alert.show(invitesgrid.rowHeight.toString());
	var rowcount:Number=14;
	if (sites.length() < 14)rowcount=sites.length();
	//invitesgrid.rowCount=rowcount;
	adepts_height=20 * rowcount;
	//}
}

private function accept_pass():void{
	confirmator_save.visible=false;
	var variables:URLVariables = new URLVariables();
	variables.sd = new String(CRYPTER.encode(password.text));
	variables.od = new String(CRYPTER.encode(oldpassword.text));
	if(iam!='0')variables.user_id=iam;
	link_to_remote("http://oxnull.net/flex/password_change/",variables);
	if(iam=='0'){
		showenter();
		Alert.show("Войдите заново под новым паролем",'Смена пароля');
	}
	else{
		Alert.show("Пароль сохранен");
	}
	
}
private function confirmator_func():void{
	confirmator.setStyle("fontWeight","bold");
	confirmator.blurWeight=1.2;
	if(password.text!=password_confirmation.text || password.text=='123456ss'){
		confirmator_save.visible=false;
		confirmator.setStyle("color","#FF0000");
		confirmator.allColor=0xFF0000;
	}
	else{
		confirmator_save.visible=true;
		confirmator.setStyle("color","#198907");
		confirmator.allColor=0x198907;
	}
}

public function loadquotas(event:TimerEvent=null):void{
	if(enterbutton.text=="Вход")return void;
	//if(catalog)catalog.load_tag_list();
	var clientsXML:XML;
	var loader:URLLoader=new URLLoader();
	var request:URLRequest=new URLRequest("http://oxnull.net/flex/my_site.xml");
	var variables:URLVariables = new URLVariables();
	variables.p = new String('p');
	if(iam!='0')variables.user_id=iam;
	request.method = URLRequestMethod.POST;
	request.data = variables;
	loader.load(request);
	loader.addEventListener(Event.COMPLETE, onComplete);

	function onComplete(event:Event):void{
		var loader:URLLoader=URLLoader(event.target);
		var rowcount:Number=10;
		clientsXML=new XML(loader.data);
		quotas=clientsXML.qoutas.children();
		sites=clientsXML.invites.children();
		rebuilder();
		infoXML=clientsXML;
		if(clientsXML.status.toString()=='2' && rebuildlabel!="Пересоздать")whoiam(false);
		rebuildlabel="Пересоздать";
		rebuildbool=true;
		deattboolb=true;
		if(clientsXML.status.toString()=='0'){
			rebuildlabel="Создается";
			rebuildbool=false;
			deattboolb=false;
		}
		if(clientsXML.status.toString()=='1'){
			rebuildlabel="Пересоздается";
			rebuildbool=false;
			deattboolb=false;
		}
		if (myTimerStatus)
		{
			myTimerStatus=false;
			plus5=0;
			myTimer.addEventListener(TimerEvent.TIMER, loadquotas);
			myTimer.start();
		}
	}
}
