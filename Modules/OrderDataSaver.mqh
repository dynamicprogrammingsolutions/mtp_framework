//
class COrderDataSaver : public CServiceProvider
{
public:
   TraitGetType { return classOrderDataSaver; }
   TraitAppAccess
   
   bool savetofile_at_remove;
   bool savetofile_at_chart_change;
   bool savetofile_at_chart_close;
   bool savetofile_at_parameter_change;
   bool savetofile_at_template_change;
   bool savetofile_at_terminal_close;
   
   bool loadfromfile;
   string datafile;
   
   COrderDataSaver()
   {
      savetofile_at_remove = true;
      savetofile_at_chart_change = false;
      savetofile_at_chart_close = false;
      savetofile_at_parameter_change = false;
      savetofile_at_template_change = false;
      savetofile_at_terminal_close = true;
   
      loadfromfile = true;
      datafile = "save_dps_"+(string)(int)__DATETIME__;
   }

   virtual void OnInit()
   {
      if (loadfromfile) {
         string filename = datafile+"_"+Symbol()+".dat";
         if (FileIsExist(filename))
         {
            Print("loading from file");
            int handle = FileOpen(filename,FILE_READ|FILE_BIN);
            if(handle==INVALID_HANDLE) {
               Print("Operation FileOpen failed, error ",GetLastError()); 
            }
            if (!App().ordermanager.Load(handle)) {
               Print("file load failed");
            }
            FileClose(handle);
            FileDelete(filename);
         }      
      }   
   }
   
   virtual void OnDeinit()
   {
      Print("uninit reason: "+(string)UninitializeReason());
      string filename = datafile+"_"+Symbol()+".dat";
      if ((savetofile_at_remove && UninitializeReason() == REASON_REMOVE) ||
      (savetofile_at_chart_change && UninitializeReason() == REASON_CHARTCHANGE) ||
      (savetofile_at_chart_close && UninitializeReason() == REASON_CHARTCLOSE) ||
      (savetofile_at_parameter_change && UninitializeReason() == REASON_PARAMETERS) ||
      (savetofile_at_template_change && UninitializeReason() == REASON_TEMPLATE) ||
      (savetofile_at_terminal_close && UninitializeReason() == REASON_CLOSE)) {
         Print("saving to file: "+filename);
         ResetLastError(); 
         int handle = FileOpen(filename,FILE_WRITE|FILE_BIN);
         if(handle==INVALID_HANDLE) {
            Print("Operation FileOpen failed, error ",GetLastError()); 
         }
         if (!App().ordermanager.Save(handle)) {
            Print("file save failed");
         }
         FileClose(handle);
      } else {
         FileDelete(filename);
      }   
   }
   
};