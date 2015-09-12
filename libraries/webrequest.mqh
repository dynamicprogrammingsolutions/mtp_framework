//
#include "commonfunctions.mqh"
#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>

#import "internet_access.dll"
   string get_webpage(string Address);
   int get_webpage_async_start(string Address);
   void get_webpage_async_wait(int id);
   void get_webpage_async_delete(int id);
   string get_webpage_async_get(int id);
   string internet_access_last_error();
   int internet_access_memory_used();
#import

enum ENUM_WEBREQUEST_STATUS {
   WR_STATUS_PENDING = 0,
   WR_STATUS_SENT = 1,
   WR_STATUS_RECEIVED = 2,
   WR_STATUS_FAILED = 3   
};
   
class CWebRequest : public CObject
{
protected:
   ENUM_WEBREQUEST_STATUS status;
   ENUM_WEBREQUEST_STATUS laststatus;
   int reqid;
   datetime sent_at;
   
public:
   static int timeout;
   static bool logging_enabled;
   string url;
   string result;
   bool remove;
   bool eventsenabled;
   CArrayObj* container;
   
   ~CWebRequest()
   {
      if (status == WR_STATUS_SENT) {
         if (logging_enabled) Print("Delete ongoing request id "+reqid);
         get_webpage_async_delete(reqid);
         CheckError();
      }
   }
   ENUM_WEBREQUEST_STATUS Status() { return(status); }   
   void Status(ENUM_WEBREQUEST_STATUS newstatus);   
   bool StatusChanged() { return(status != laststatus); }
   virtual void Send();
   void CheckError() const;
   
   virtual void Check();
   virtual void OnCheck() {}
   virtual void OnFailed() {}
   virtual void OnReceived() {}
   virtual void OnFinished() { this.remove = true; }
   virtual bool OnBeforeSend() { return true; }
   virtual void OnAfterSend() {}
   virtual void OnDelete() {}
   
};

int CWebRequest::timeout = 15;
bool CWebRequest::logging_enabled = false;

class CWebRequestContainer : public CArrayObj
{
protected:
   /*void CheckStatus(CWebRequest* request)
   {      
      if (eventsenabled && request.StatusChanged()) {
         switch (request.Status()) {
            case WR_STATUS_SENT: OnAfterSend(request); break;
            case WR_STATUS_FAILED: OnFailed(request); OnFinished(request); break;
            case WR_STATUS_RECEIVED: OnReceived(request); OnFinished(request); break;
         }
      }   
   }*/

public:
   bool eventsenabled;

   virtual CWebRequest* GetNewWebRequest() { return(new CWebRequest()); }

   virtual void CheckAll()
   {
      for (int i = 0; i < Total(); i++) {
         if (!isset(At(i))) Delete(i);
         CWebRequest* request = At(i);
         request.Check();
         if (request.remove) {
            request.OnDelete();
            OnDelete(request);
            Delete(i);
         }
      }
      if (eventsenabled) OnCheckAll();
   }
   
   bool Add(CObject *element) {
      ((CWebRequest*)element).container = GetPointer(this);
      return CArrayObj::Add(element);
   }
   
   virtual CWebRequest* NewRequest(CWebRequest* request, string url) {
      request.url = url;
      Add(request);
      return request;
   }
   
   virtual CWebRequest* NewRequest(string url) {
      CWebRequest* request = GetNewWebRequest();
      request.url = url;
      Add(request);
      return request;
   }

   void SendRequest(CWebRequest* request) {
      request.Send();
   }

   virtual void SendRequest(CWebRequest* request, string url) {
      NewRequest(request, url);
      SendRequest(request);
   }
   
   virtual void SendRequest(string url) {
      CWebRequest* request = NewRequest(url);
      SendRequest(request);
   }
   

   virtual void OnCheckAll() {}
   virtual void OnCheck(CWebRequest* request) {}
   virtual void OnFailed(CWebRequest* request) {}
   virtual void OnReceived(CWebRequest* request) {}
   virtual void OnFinished(CWebRequest* request) {}
   virtual bool OnBeforeSend(CWebRequest* request) { return true; }
   virtual void OnAfterSend(CWebRequest* request) {}
   virtual void OnDelete(CWebRequest* request) {}

};


void CWebRequest::Status(ENUM_WEBREQUEST_STATUS newstatus)
{
   laststatus = status;
   status = newstatus;
   if (status != laststatus) {
      if (eventsenabled) {
         switch (status) {
            case WR_STATUS_SENT: OnAfterSend(); break;
            case WR_STATUS_FAILED: OnFailed(); OnFinished(); break;
            case WR_STATUS_RECEIVED: OnReceived(); OnFinished(); break;
         }
      }
      if (isset(container)) {
         CWebRequestContainer* _container = (CWebRequestContainer*)container;
         if (_container.eventsenabled) {
            switch (status) {
               case WR_STATUS_SENT: _container.OnAfterSend(GetPointer(this)); break;
               case WR_STATUS_FAILED: _container.OnFailed(GetPointer(this)); _container.OnFinished(GetPointer(this)); break;
               case WR_STATUS_RECEIVED: _container.OnReceived(GetPointer(this)); _container.OnFinished(GetPointer(this)); break;
            }
         }
      }
   }
}

void CWebRequest::Send() {
   if (status == WR_STATUS_PENDING || status == WR_STATUS_FAILED) {

      bool enabled = true;

      if (eventsenabled) enabled &= OnBeforeSend();

      if (isset(container)) {
         CWebRequestContainer* _container = (CWebRequestContainer*)container;
         if (_container.eventsenabled) enabled &= _container.OnBeforeSend(GetPointer(this));
      }

      if (enabled) {
   
         this.sent_at = TimeCurrent();
         reqid = get_webpage_async_start(url);
         CheckError();
         
         if (reqid >= 0) {
            Status(WR_STATUS_SENT);
         } else {
            Status(WR_STATUS_FAILED);
         }
         
      }
      
   }   
   
}

void CWebRequest::Check() {
   if (status == WR_STATUS_SENT) {
      result = get_webpage_async_get(reqid);
      if (result == "Not finished") {
         if (TimeCurrent()-sent_at > timeout) {
            get_webpage_async_delete(reqid);
            CheckError();
            Status(WR_STATUS_FAILED);
         }
      } else if (result == "No Process") {
         Status(WR_STATUS_FAILED);
      } else {
         Status(WR_STATUS_RECEIVED);
      }
   }
   if (eventsenabled) {
      OnCheck();
   }
   
   if (isset(container)) {
      CWebRequestContainer* _container = (CWebRequestContainer*)container;
      if (_container.eventsenabled) {
         _container.OnCheck(GetPointer(this));
      }
   }
}

void CWebRequest::CheckError() const {
   string error = internet_access_last_error();
   if (error != "") Print("internet_access error: "+error);
}

/*

class CWebRequestExt : public CWebRequest
{
   CWebRequestExt()
   {
      eventsenabled = true;
   }
   
   virtual void OnCheck() {}
   virtual void OnFailed() {}
   virtual void OnReceived() {}
   virtual void OnFinished() {}
   virtual bool OnBeforeSend() { return true; }
   virtual void OnAfterSend() {}
   virtual void OnDelete() {}
   
};

class CWebRequestContainerExt : public CWebRequestContainer
{
   CWebRequestContainerExt()
   {
      eventsenabled = true;
   }   

   virtual void OnCheckAll() {}
   virtual void OnCheck(CWebRequest* request) {}
   virtual void OnFailed(CWebRequest* request) {}
   virtual void OnReceived(CWebRequest* request) {}
   virtual void OnFinished(CWebRequest* request) {}
   virtual bool OnBeforeSend(CWebRequest* request) { return true; }
   virtual void OnAfterSend(CWebRequest* request) {}
   virtual void OnDelete(CWebRequest* request) {}   
};

*/
