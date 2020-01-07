#include <Object.mqh>;

#import "WebSocket_Lib.dll"
   int ws_open_connection(string url, int polling);
   void ws_close_connection(int handle);
   int ws_get_connection_status(int handle);

   int ws_count_messages(int handle);
	void ws_get_message_by_char(int handle);
	bool ws_get_message_haschar(int handle);
	ushort ws_get_message_nextchar(int handle);
	
	//void ws_get_message(int handle, string& message);
	//void ws_delete_message(int handle, string& message);
	
	void ws_send_message(int handle, string message);
	void ws_send_binary(int handle, string message);
	
	//string ws_get_converted_message(string message);

#import

string ws_get_message(int handle)
{
   ws_get_message_by_char(handle);
   string str = "";
   int pos = 0;
   while(ws_get_message_haschar(handle)) {
      ushort ch = ws_get_message_nextchar(handle);
      //ushort ushort_ch = ch+0;
      if (!StringSetCharacter(str,pos,ch)) {
         Print("Error writing string");
      }
      pos++;
   }
   return str;
}

string ws_encode_message(string message)
{
   string resstr = "";
   int respos = 0;
   ushort ch, char1, char2, char3, char4;
   for (int i = 0; i < StringLen(message); i++) {
      ch = StringGetCharacter(message,i);
      if (((ch^0x20) & 0x80) == 0x80) { 
         StringSetCharacter(resstr,respos,0x5e);
         respos++;
         StringSetCharacter(resstr,respos,0x60);
         respos++;
         char1 = ((ch^0x20) & 0x003f)^0x20;
         char2 = (((ch^0x20) & 0x0fc0) >> 6)^0x20;
         char3 = (((ch^0x20) & 0x0f00) >> 12)^0x20;
         StringSetCharacter(resstr,respos,char1);
         respos++;
         StringSetCharacter(resstr,respos,char2);
         respos++;
         StringSetCharacter(resstr,respos,char3);
         respos++;
         StringSetCharacter(resstr,respos,char4);
         respos++;
      } else {
         StringSetCharacter(resstr,respos,ch);
         respos++;
      }
   }
   Print(resstr);
   return resstr;
}

string ws_decode_message(string message)
{
   string resstr = "";
   int srcpos = 0;
   int trgpos = 0;
   ushort ch, char1, char2, char3;
   while (srcpos < StringLen(message)) {
      char1 = StringGetCharacter(message,srcpos);
      srcpos++;
      if (srcpos < StringLen(message)) {
         char2 = StringGetCharacter(message,srcpos);
         srcpos++;
         if (char1 == 0x5e && char2 == 0x60) {
            char1 = StringGetCharacter(message,srcpos+0);
            char2 = StringGetCharacter(message,srcpos+1);
            char3 = StringGetCharacter(message,srcpos+2);
            srcpos+=3;
            ch = ((char1^0x20 & 0x3f) | ((char2^0x20 & 0x3f) << 6) | ((char3^0x20 & 0x3f) << 12))^0x20;
            StringSetCharacter(resstr,trgpos,ch);
            trgpos++;
         } else {
            StringSetCharacter(resstr,trgpos,char1);
            trgpos++;
            StringSetCharacter(resstr,trgpos,char2);
            trgpos++;
         }
      } else {
         StringSetCharacter(resstr,trgpos,char1);
         trgpos++;
      }
      
   }
   return resstr;
}

enum ENUM_WEB_SOCKET_CONNECTION_STATE {
   wsNotConnected,
   wsConnected,
   wsFailed,
   wsClosed
};

class CWsMessageHandler : public CObject {
public:
   virtual void HandleMessage(string message) {}   
};

class CWebSocketConnection : public CObject {
private:
   ENUM_WEB_SOCKET_CONNECTION_STATE m_state;
   string m_url;
   int m_polling_interval;
   int m_handle;
   bool m_use_encoding;
   CWsMessageHandler* m_message_handler;
public:
   CWebSocketConnection(int polling_interval): m_state(wsNotConnected), m_polling_interval(polling_interval) {
      
   }
   CWebSocketConnection(string url, int polling_interval): m_state(wsNotConnected), m_polling_interval(polling_interval) {
      Connect(url);
   }
   ~CWebSocketConnection()
   {
      if (m_state == wsConnected) {
         Disconnect();
      }
      delete m_message_handler;
   }
public:
   ENUM_WEB_SOCKET_CONNECTION_STATE State() { return m_state; }
   void PollingInterval(int polling_interval) { m_polling_interval = polling_interval; }
   int PollingInterval() { return m_polling_interval; }
   void UseEncoding(bool use_encoding) { m_use_encoding = use_encoding; }
   bool UseEncoding() { return m_use_encoding; }
   void MessageHandler(CWsMessageHandler* message_handler) { m_message_handler = message_handler; }
   CWsMessageHandler* MessageHandler() { return m_message_handler; }

   bool Connect(string url, bool may_reconnect = false)
   {
      if (m_state == wsConnected) {
         if (may_reconnect) this.Disconnect();
         else return false;
      }
      m_url = url;
      Print("connecting to url: ",url);
      m_handle = ws_open_connection(url,m_polling_interval);
      Print("handle: ",m_handle);
      if (m_handle >= 0) m_state = wsConnected;
      else m_state = wsFailed;
      return (m_state == wsConnected);
   }
   bool Disconnect()
   {
      if (m_state != wsConnected) return false;
      ws_close_connection(m_handle);
      m_state = wsClosed;
      return true;
   }
   string GetNextMessage()
   {
      if (m_state != wsConnected) {
         Print(__FUNCTION__,": not connected");
         return NULL;
      }
      if (ws_count_messages(m_handle) == 0) return NULL;
      else {
         string message = ws_get_message(m_handle);
         if (m_use_encoding) return ws_decode_message(message);
         return message;
      }
   }
   bool SendMessage(const string message)
   {
      if (m_state != wsConnected) {
         Print(__FUNCTION__,": not connected");
         return false;
      }
      if (m_use_encoding) ws_send_message(m_handle,ws_encode_message(message));
      else ws_send_message(m_handle,message);
      return true;
   }
   bool PollMessages()
   {
      if (m_state != wsConnected) {
         Print(__FUNCTION__,": not connected");
         return false;
      }
      if (CheckPointer(m_message_handler) == POINTER_INVALID) {
         Print(__FUNCTION__,": invalid message handler");
         return false;
      }
      int cnt = ws_count_messages(m_handle);
      for (int i = 0; i < cnt; i++) {
         string message = ws_get_message(m_handle);
         m_message_handler.HandleMessage(message);
      }
      return true;
   }
};

