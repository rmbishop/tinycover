/*Copyright notice is at bottom of file.*/

#define TINY_COVER_VERSION "0.9.4"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "libtinycover.c"
#include "tinycover_utils.c"
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>

#ifdef WIN32 
#include "windows.h"
#else
#include <dirent.h> 
#endif

#ifdef MSVC
#include <direct.h>
#define mkdir(p,m) _mkdir(p)
#endif

int path_exists(char *path);

int show_usage()
{
   printf("tinycover new <folder path>\n");   
   printf("tinycover inst <folder path>\n");
   printf("tinycover report <folder path>\n");
   printf("tinycover version\n");
   return 0;
}

const char *build_path_string(lua_State *L, char *part1, char *part2)
{
   luaL_Buffer b;
   luaL_buffinit(L, &b);
   luaL_addstring(&b,part1);
   luaL_addstring(&b,"/");  
   luaL_addstring(&b,part2);    
   luaL_pushresult(&b);
   return lua_tostring(L, -1);
}

int new_project(char *project_path)
{
   FILE *config_file;
   const char *file_path;
   int r;
   lua_State *L;

   L = luaL_newstate();  /* create state */
   luaL_openlibs(L);

   /*Make the root project folder*/
   if(path_exists(project_path)) 
   {
      printf("Error creating project.  %s already exists\n",project_path);
      lua_close(L);
      return 1;
   }

   printf("Creating folder %s\n",project_path);
   r = mkdir(project_path,0777);
   if(0 != r) 
   {
      printf("Error creating %s\n",project_path);
      lua_close(L);
      return 1;
   }

   /*Make the dat folder within*/
   file_path = build_path_string(L,project_path,"data");
   printf("Creating folder %s/data\n",project_path);
   r = mkdir(file_path,0777);
   if(0 != r) 
   {
      printf("Error creating %s\n",project_path);
      lua_close(L);
      return 1;
   }   

   /*Make the src folder within*/
   printf("Creating folder %s/src\n",project_path);
   file_path = build_path_string(L,project_path,"src");
   r = mkdir(file_path,0777);   
   if(0 != r) 
   {
      printf("Error creating %s\n",project_path);
      lua_close(L);
      return 1;
   }      

   /*Make the instrumented folder within*/
   printf("Creating folder %s/instrumented\n",project_path);   
   file_path = build_path_string(L,project_path,"instrumented");
   r = mkdir(file_path,0777);      
   if(0 != r) 
   {
      printf("Error creating %s\n",project_path);
      lua_close(L);
      return 1;
   }       

   /*Make the reports folder within*/
   printf("Creating folder %s/reports\n",project_path);   
   file_path = build_path_string(L,project_path,"reports");
   r = mkdir(file_path,0777);       
   if(0 != r) 
   {
      printf("Error creating %s\n",project_path);
      lua_close(L);
      return 1;
   }       

   /*Make the info folder within*/
   printf("Creating folder %s/info\n",project_path);      
   file_path = build_path_string(L,project_path,"info");
   r = mkdir(file_path,0777);   
   if(0 != r) 
   {
      printf("Error creating %s\n",project_path);
      lua_close(L);
      return 1;
   }    

   /*Write the config file*/
   printf("Creating config file %s/config.lua\n",project_path);      
   file_path = build_path_string(L,project_path,"config.lua");
   config_file = (FILE *)fopen(file_path,"w");
   if(NULL == config_file) 
   {
      printf("Error creating %s\n",file_path);
      lua_close(L);
      return 1;
   } 
   fprintf(config_file,"--Coverage = \"MCDC\"\n");   
   fprintf(config_file,"--Coverage = \"Statement\"\n"); 
   fprintf(config_file,"--Coverage = \"Decision\"\n"); 
   fprintf(config_file,"--Coverage = \"Decision+Statement\"\n");    
   fprintf(config_file,"Coverage = \"MCDC+Statement\"\n");
   fprintf(config_file,"ArrayName = \"tc_coverage\"\n");
   fprintf(config_file,"StartingArrayIndex = 0\n");
   fprintf(config_file,"\n");
   fprintf(config_file,"--File names that are in this list will not be instrumented.\n");
   fprintf(config_file,"--They will be copied as is to the Instrumented folder.\n");
   fprintf(config_file,"DisableCoverage = {\n");
   fprintf(config_file,"}\n");
   fprintf(config_file,"\n");
   fprintf(config_file,"--Example.\n");
   fprintf(config_file,"--DisableCoverage = {\n");
   fprintf(config_file,"--   \"myFile.c\",\n");
   fprintf(config_file,"--}\n");
   fprintf(config_file,"\n");
   
   fclose(config_file);
   lua_close(L);
   return 0;
}

#ifdef WIN32
int path_exists(char *path)
{
   WIN32_FIND_DATA ffd;
   HANDLE dirHandle = INVALID_HANDLE_VALUE;   
   dirHandle = FindFirstFile(path, &ffd);
   return INVALID_HANDLE_VALUE != dirHandle;
}

int process_directory(lua_State *L, char *folder, char *search_string, char *project_path, char *lua_function)
{
   WIN32_FIND_DATA ffd;
   HANDLE dirHandle = INVALID_HANDLE_VALUE;   
   const char *full_search_string;
   
   /*Create search string*/
   full_search_string = build_path_string(L,(char *)build_path_string(L,project_path,folder),search_string);
   
   dirHandle = FindFirstFile((char *)full_search_string, &ffd);
   do 
   {
      if(INVALID_HANDLE_VALUE != dirHandle) 
      {
         if(ffd.dwFileAttributes != FILE_ATTRIBUTE_DIRECTORY) 
         {
            int r = 0;
            lua_getglobal(L, lua_function);
            lua_pushstring(L,project_path);
            lua_pushstring(L,ffd.cFileName);
            lua_pcall(L, 2, 1, 0);  

            r = (int)lua_tointeger(L, -1);

            if(r != 0) 
            {
               break;
            } 
         }
      }
   }
   while (FindNextFile(dirHandle, &ffd) != 0);

   return 0;  
}
#else
int path_exists(char *path)
{
   DIR *d = NULL;
   struct dirent *dir_ent = NULL;
   unsigned int return_val = 0;
  
   d = opendir(path);

   if (d) 
   {
      dir_ent = readdir(d);
       
       if(NULL != dir_ent)
       { 
	      return_val = 1;
       }       
   }

   closedir(d);

   return return_val;    
}

int process_directory(lua_State *L, char *folder, char *search_string, char *project_path, char *lua_function)
{
   DIR *d = NULL;
   const char *full_search_string;
   struct dirent *dir_ent = NULL;
   
   /*Create search string*/
   full_search_string = build_path_string(L,project_path,folder);

   d = opendir(full_search_string);
   
   if (d) 
   {
      while(1)
      {
         dir_ent = readdir(d);
         
         if(NULL == dir_ent)
         {
           break;
         }
  
         if(DT_REG == dir_ent->d_type)
         {
            int r = 1;
            lua_getglobal(L, lua_function);
            lua_pushstring(L,project_path);
            lua_pushstring(L,dir_ent->d_name);
            lua_pcall(L, 2, 1, 0); 
            
            r = (int)lua_tointeger(L, -1);

            if(r != 0) 
            {
               break;
            } 
         }
      }
      closedir(d);
   }

   return 0;  
}
#endif

int report(char *project_path)
{
   extern char libtinycover_buffer[];
   extern char tinycover_utils_buffer[];
   lua_State *L;
   const char *path_without_trailing_space = project_path;
   unsigned int last_char_pos = 0;

   L = luaL_newstate();  /* create state */
   luaL_openlibs(L);
   last_char_pos = strlen(project_path) - 1;   

   if(last_char_pos > 1) 
   {
      if(('\\' == project_path[last_char_pos]) ||
         (('/' == project_path[last_char_pos])))
      {
         /*If the string ends in a directory separator, remove the separator*/
         luaL_Buffer b;
         luaL_buffinit(L, &b);
         luaL_addlstring(&b,project_path,last_char_pos);
         luaL_pushresult(&b);
         path_without_trailing_space = lua_tostring(L, -1);
      }
   }
   if(!path_exists((char *)path_without_trailing_space)) 
   {
      printf("Error. %s does not exist.\n",path_without_trailing_space);
      return 1;
   }

   L = luaL_newstate();  /* create state */
   luaL_openlibs(L);

   /*Load libtinycover.lua into memory*/
   luaL_dostring(L,libtinycover_buffer);

   /*Load tinycover_utils.lua into memory*/
   luaL_dostring(L,tinycover_utils_buffer);

   process_directory(L, "data","*.dat",(char *)path_without_trailing_space, "tc_read_data_file");
   process_directory(L, "info","*.inst.info",(char *)path_without_trailing_space, "tc_generate_results");

   lua_close(L);

   return 0;
}

int instrument_project(char *project_path)
{
   extern char libtinycover_buffer[];
   extern char tinycover_utils_buffer[];
   lua_State *L;
   const char *path_without_trailing_space = project_path;
   unsigned int last_char_pos = 0;

   L = luaL_newstate();  /* create state */
   luaL_openlibs(L);
   last_char_pos = strlen(project_path) - 1;

   if(last_char_pos > 1) 
   {
      if(('\\' == project_path[last_char_pos]) ||
         (('/' == project_path[last_char_pos])))
      {
         /*If the string ends in a directory separator, remove the separator*/
         luaL_Buffer b;
         luaL_buffinit(L, &b);
         luaL_addlstring(&b,project_path,last_char_pos);
         luaL_pushresult(&b);
         path_without_trailing_space = lua_tostring(L, -1);
      }
   }
   if(!path_exists((char *)path_without_trailing_space)) 
   {
      printf("Error.  %s does not exist.",path_without_trailing_space);
      lua_close(L);
      return 1;
   }

   /*Load libtinycover.lua into memory*/
   luaL_dostring(L,libtinycover_buffer);

   /*Load tinycover_utils.lua into memory*/
   luaL_dostring(L,tinycover_utils_buffer);
   process_directory(L, "src", "*.*",(char *)path_without_trailing_space, "tc_instrument");
  
   lua_close(L);
   
   return 0;
}

int main(int argc, char **argv)
{
   if(argc == 2) 
   {
      if(0 == strncmp(argv[1],"version",7)) 
      {
         printf("%s\n",TINY_COVER_VERSION);
         return 0;
      }   
      else
      {
         show_usage();
         return 1;
      }
   }
   else if(argc != 3)
   {
      show_usage();
      return 1;
   }   
 
   if(0 == strncmp(argv[1],"new",7)) 
   {    
      new_project(argv[2]);  
   }
   else if(0 == strncmp(argv[1],"inst",7)) 
   {
      instrument_project(argv[2]);  
   }
   else if(0 == strncmp(argv[1],"report",7)) 
   {
      report(argv[2]);  
   }
   else 
   {
      show_usage();
      return 1;
   }
 
    return 0;
}

/*
Copyright (c) 2023 Ryan Kluzak

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/