#include "..\Loader.mqh"

#include <Controls\Button.mqh>
class CActionButton : public CButton
{
public:
   CAppObject* callback;
   int callback_id;
   CActionButton(CAppObject* _callback, int _callback_id)
   {
      callback = _callback;
      callback_id = _callback_id;
   }
   void Check()
   {
      if (Pressed()) {
         Print("button "+this.Name()+" has been pressed");
         Pressed(!Pressed());
         if (isset(callback)) {
            CObject* obj = NULL;
            callback.callback(callback_id,obj);
         }
      }
   }
};

class CButtonManager : public CServiceProvider
{
public:
   CAppObjectArrayObj buttons;
   CActionButton* AddButton(string _name, string text, int x, int y, int w, int h, color cl, CAppObject* callback, int callback_id)
   {
      CActionButton* button = new CActionButton(callback,callback_id);
      button.Create(ChartID(),_name,0,x,y,x+w,y+h);
      button.Color(cl);
      button.Text(text);
      buttons.Add(button);
      return button;
      
   }
   void RemoveButton(string _name)
   {
      for (int i = buttons.Total()-1; i >= 0; i--) {
         CActionButton* button = buttons.At(i);
         if (button.Name() == _name) buttons.Delete(i);
      }
      
   }
   virtual void OnTimer()
   {
      /*CActionButton* button;
      while(buttons.ForEach(button)) {
         button.Check();
      }*/
   }
   virtual void OnChartEvent(int id,long lparam,double dparam,string sparam)
   {
      CActionButton* button;
      while(buttons.ForEach(button)) {
         button.Check();
      }
   }
};
