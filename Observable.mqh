#include "Loader.mqh"
#define OBSERVABLE_H

class CObservable : public CAppObject
{
protected:
   CArrayObject<CAppObject> observers;
   
public:
   void AddObserver(CAppObject* observer) {
      this.observers.Add(observer);
   }
   
   void Dispatch(const int event_id, CObject* signal, bool delete_event = false) {
      int total = observers.Total();
      for (int i = 0; i < total; i++) {
         CAppObject* observer = observers.At(i);
         observer.EventCallback(event_id,signal);
      }
      if (delete_event) delete signal;
   }
   
   CObject* DispatchWithResult(const int event_id, CObject* signal = NULL, bool delete_event = false) {
      int total = observers.Total();
      CObject* result = NULL;
      for (int i = 0; i < total; i++) {
         CAppObject* observer = observers.At(i);
         observer._callback_result = NULL;
         observer.EventCallback(event_id,signal);
         if (observer._callback_result != NULL) {
            result = observer._callback_result;
            break;
         }
      }
      if (delete_event) delete signal;
      return result;
   }
   
   void Dispatch(const int event_id) {
      int total = observers.Total();
      for (int i = 0; i < total; i++) {
         CAppObject* observer = observers.At(i);
         observer.EventCallback(event_id,NULL);
      }
   }
   
};

class CObservableServiceProvider : public CServiceProvider
{
protected:
   CArrayObject<CAppObject> observers;
   
public:
   void AddObserver(CAppObject* observer) {
      this.observers.Add(observer);
   }
   
   void Dispatch(const int event_id, CObject* signal, bool delete_event = false) {
      int total = observers.Total();
      for (int i = 0; i < total; i++) {
         CAppObject* observer = observers.At(i);
         observer.EventCallback(event_id,signal);
      }
      if (delete_event) delete signal;
   }
   
   CObject* DispatchWithResult(const int event_id, CObject* signal = NULL, bool delete_event = false) {
      int total = observers.Total();
      CObject* result = NULL;
      for (int i = 0; i < total; i++) {
         CAppObject* observer = observers.At(i);
         observer._callback_result = NULL;
         observer.EventCallback(event_id,signal);
         if (observer._callback_result != NULL) {
            result = observer._callback_result;
            break;
         }
      }
      if (delete_event) delete signal;
      return result;
   }
   
   void Dispatch(const int event_id) {
      int total = observers.Total();
      for (int i = 0; i < total; i++) {
         CAppObject* observer = observers.At(i);
         observer.EventCallback(event_id,NULL);
      }
   }
   
};