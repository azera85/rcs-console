package it.ht.rcs.console.main
{
  import flash.events.Event;
  import flash.events.EventDispatcher;
  
  import it.ht.rcs.console.accounting.controller.GroupManager;
  import it.ht.rcs.console.accounting.controller.UserManager;
  import it.ht.rcs.console.accounting.model.User;
  import it.ht.rcs.console.agent.controller.AgentManager;
  import it.ht.rcs.console.alert.controller.AlertManager;
  import it.ht.rcs.console.controller.Manager;
  import it.ht.rcs.console.events.DataLoadedEvent;
  import it.ht.rcs.console.network.controller.CollectorManager;
  import it.ht.rcs.console.network.controller.InjectorManager;
  import it.ht.rcs.console.operation.controller.OperationManager;
  import it.ht.rcs.console.search.controller.SearchManager;
  import it.ht.rcs.console.target.controller.TargetManager;
  import it.ht.rcs.console.utils.Update;
  
  import mx.collections.ArrayList;
  import mx.controls.ProgressBar;
  
  public class Initialization extends EventDispatcher
  {
    
    private static var _instance:Initialization = new Initialization();
    public static function get instance():Initialization { return _instance; }
    
    private var maxGreenLights:int;
    private var currentGreenLights:int;
    
    private var progress:ProgressBar;
    
    public var mainSections:ArrayList;
    
    public function initialize(loading:ProgressBar):void
    {
      progress = loading;
      
      maxGreenLights = 0;
      currentGreenLights = 0;
      mainSections = new ArrayList();
      
      var user:User = Console.currentSession.user;

      if (user.is_any())                                       mainSections.addItem({label: 'Home',       manager: null});
      if (user.is_admin())                                     mainSections.addItem({label: 'Accounting', manager: null});
      if (user.is_admin() || user.is_tech() || user.is_view()) mainSections.addItem({label: 'Operations', manager: null});
      if (user.is_view())                                      mainSections.addItem({label: 'Dashboard',  manager: null});
      if (user.is_view())                                      mainSections.addItem({label: 'Alerting',   manager: AlertManager, property: 'alertCount'});
      if (user.is_sys() || user.is_tech())                     mainSections.addItem({label: 'System',     manager: null});
      if (user.is_admin())                                     mainSections.addItem({label: 'Audit',      manager: null});
      if (user.is_admin() || user.is_sys())                    mainSections.addItem({label: 'Monitor',    manager: null});
    //if (user.is_any())                                       mainSections.addItem({label: 'Playground', manager: null});
      
      
      var managers:Array = [];
      
      // Initialize the managers
      
//      if (user.is_any())
//      {
//        SearchManager.instance.listenRefresh();
//        SearchManager.instance.refresh();
//        
//        CollectorManager.instance.refresh();
//        
//        //LicenseManager.instance.start();
//        
//        //DownloadManager.instance.listenRefresh();
//        //DownloadManager.instance.refresh();
//      }
//      
//      
//      if (user.is_admin())
//      {
//        GroupManager.instance.refresh();
//      }
//      
//      if (user.is_admin() || user.is_tech() || user.is_view())
//      {
//        OperationManager.instance.refresh();
//        TargetManager.instance.refresh();
//      }
//      
//      if (user.is_tech() || user.is_view())
//      {
//        AgentManager.instance.refresh();
//      }
//      
////      if (user.is_admin() || user.is_sys()) {
////        MonitorManager.instance.start_counters();        
////      }
//      
////      if (user.is_view()) {
////        AlertController.instance.start_counters();
////      }
      Update.check();
      
      if (user.is_any())
      {
        SearchManager.instance.listenRefresh();
        managers.push(SearchManager.instance);
        managers.push(CollectorManager.instance);
      }
      
      if (user.is_admin())
      {
        managers.push(UserManager.instance);
        managers.push(GroupManager.instance);
      }
      
      if (user.is_admin() || user.is_tech() || user.is_view())
      {
        managers.push(OperationManager.instance);
        managers.push(TargetManager.instance);
      }
      
      if (user.is_tech() || user.is_view())
      {
        managers.push(AgentManager.instance);
      }
      
      if (user.is_tech())
      {
        managers.push(InjectorManager.instance);
      }
      
      maxGreenLights = managers.length;
      for each (var manager:Manager in managers) {
        manager.addEventListener(DataLoadedEvent.DATA_LOADED, onDataLoaded);
        manager.refresh();
      }
      
    }
    
    private function onDataLoaded(event:DataLoadedEvent):void
    {
      event.manager.removeEventListener(DataLoadedEvent.DATA_LOADED, onDataLoaded);
      currentGreenLights++;
      progress.setProgress(currentGreenLights, maxGreenLights);
      if (currentGreenLights == maxGreenLights)
        dispatchEvent(new Event("initialized"));
    }
    
  }
  
}