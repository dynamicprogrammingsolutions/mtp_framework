//
#define TraitSendCommands CObject* CommandSend(const int _id, CObject* object = NULL, const bool deleteobject = false) { return App().commandmanager.Send(_id,object,deleteobject); }
