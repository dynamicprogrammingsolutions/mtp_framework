//

/*

#define COMMENT_ENABLE_PARAM
input bool _comments_enabled = true;

#define COMMENT_FORMAT
input bool _comment_formatting = true;
string _objname_comment = "comment_textbox";
input ENUM_BASE_CORNER _comment_corner = CORNER_RIGHT_LOWER;
#define COMMENT_AUTO_REVERSE
input int _comment_fontsize = 7;
input string _comment_font = "Tahoma";
input color _comment_color = White;
input int _comment_x = 10;
input int _comment_y = 15;
input int _comment_lineheight = 11;
int _comment_window = 0;

*/

class CChartComment : public CServiceProvider
{
public:
   TraitAppAccess
   
   virtual void OnTick()
   {
      if (comments_enabled) {
         if (comment_formatting) writecomment();
         else writecomment_noformat();
         if (printcomment) printcomment();
         delcomment();
      } else {
         delcomment();
      }
   }
   
   virtual void OnInit()
   {

#ifdef COMMENT_ENABLE_PARAM
      comments_enabled = _comments_enabled;
#endif

#ifdef COMMENT_FORMAT

      comment_formatting = _comment_formatting;
      objname_comment = _objname_comment;
      comment_corner = _comment_corner;
      
#ifdef COMMENT_AUTO_REVERSE
      if (comment_corner == CORNER_LEFT_LOWER || comment_corner == CORNER_RIGHT_LOWER)
         comment_reverse_lines = true;
      else
         comment_reverse_lines = false;
#else      
      comment_reverse_lines = _comment_reverse_lines;
#endif

      comment_fontsize = _comment_fontsize;
      comment_font = _comment_font;
      comment_color = _comment_color;
      comment_x = _comment_x;
      comment_y = _comment_y;
      comment_lineheight = _comment_lineheight;
      comment_window = _comment_window;
      
#endif

      if (IsTesting() && !IsVisualMode() && !printcomment) {    
         comments_enabled = false;
      }    
   }
   
   virtual void OnDeinit() {
      if (comments_enabled) {
         clearcomment();
      }
   }
   
};

/*

#define COMMENT_ENABLE_PARAM
input bool _comments_enabled = true;

#define COMMENT_FORMAT
input bool _comment_formatting = true;
string _objname_comment = "comment_textbox";
input ENUM_BASE_CORNER _comment_corner = CORNER_RIGHT_LOWER;
#define COMMENT_AUTO_REVERSE
input int _comment_fontsize = 7;
input string _comment_font = "Tahoma";
input color _comment_color = White;
input int _comment_x = 10;
input int _comment_y = 15;
input int _comment_lineheight = 11;
int _comment_window = 0;

*/

