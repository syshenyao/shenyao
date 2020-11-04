#-*-coding:utf-8 -*-

def random_str(randomlength=8):
    str = ''
    chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789'
    length = len(chars) - 1
    random = Random()
    for i in range(randomlength):
        str+=chars[random.randint(0, length)]
    return str
    
import sys, os, platform, sqlite3, time, codecs
import subprocess, threading
from random import Random

# Python version  -  '2' or '3'
strVersion=platform.python_version();
listTemp = strVersion.split('.');
globle_num2str_Version = listTemp[0];

# Set current directory
user_dir = sys.path[0]
os.chdir(user_dir)

# Import yaml after current dir changed to use local pyYAML module
import yaml
file_iostream = open("settings.yml", 'r')
dictSystem =  yaml.load(file_iostream)
file_iostream.close()
print("settings loaded")

# Generate a prefix
dictSession = {}
dictSession['prefix'] = random_str(8)

# Generate dir tree
print("dump dir tree to "+dictSession['prefix'])
tmpCMD = "dir /b /s >> EZT_"+dictSession['prefix']+"_dir.txt"
outSubprocess = subprocess.Popen(tmpCMD, shell=True, stdout=subprocess.PIPE).communicate()[0]

# Process dir tree
print("pick encrypted file path from "+dictSession['prefix'])
listAllFiles = []
if globle_num2str_Version == '2':
    objFile = open("EZT_"+dictSession['prefix']+"_dir.txt", 'r')
    listAllFiles = objFile.readlines().decode('gbk','ignore').encode('utf-8')
else:
    objFile = codecs.open("EZT_"+dictSession['prefix']+"_dir.txt", 'r', 'gbk')
    listAllFiles = objFile.readlines()
objFile.close()

listEncryptedFiles = []
for m_FullFilePath in listAllFiles:
    m_FullFilePath = m_FullFilePath.strip('\n').strip('\r')
    m_IsUserSelectedExts = False
    m_CurrentExt = ""
    # ext filter
    for m_UserSelectedExt in dictSystem['settings']['extansions']:
        if m_FullFilePath.endswith("."+m_UserSelectedExt):
            m_IsUserSelectedExts = True
            m_CurrentExt = m_UserSelectedExt
            break
            
    # enctypt filter
    m_IsFileEncrypted = False
    if m_IsUserSelectedExts == True:
        grpStrTempLine = ""
        objFile = open(m_FullFilePath, 'r', encoding='utf-8',errors='ignore')
        grpStrTempLine = objFile.readlines(1)
        objFile.close()
        # print(grpStrTempLine[0])
        if len(grpStrTempLine) == 1 and "E-SafeNet" in grpStrTempLine[0]:
            m_IsFileEncrypted = True
        if len(grpStrTempLine) == 1 and grpStrTempLine[0].startswith( 'b' ):
            m_IsFileEncrypted = True
            
    if m_IsUserSelectedExts and m_IsFileEncrypted:
        listEncryptedFiles.append(m_FullFilePath)
        if m_CurrentExt in dictSystem['mappings']['extansions']:
            m_Key = dictSystem['mappings']['extansions'][m_CurrentExt]
            dictSystem['data'][m_Key] = True
        
        

# save encrypted file path
outfile = open("EZT_"+dictSession['prefix']+"_list.txt",'w')
for line in listEncryptedFiles:
    outfile.write(line+'\n')
outfile.close()

print("find "+str(len(listEncryptedFiles))+" encrypted files; sending them to workers")

for m_HandlerProcess in dictSystem['data']:
    strCMD = m_HandlerProcess + " -session " + dictSession['prefix']
    outSubprocess = subprocess.Popen(strCMD, shell=True, stdin=None, stdout=None, stderr=None, close_fds=True)

if globle_num2str_Version == '2':
    typein = raw_input("After all workers reach their final line, press Enter to continue\n");
elif globle_num2str_Version == '3':
    typein = input("After all workers reach their final line, press Enter to continue\n");
    typein=str(typein);
    

for line in listEncryptedFiles:
    line_new = line + ".YZT_" + dictSession['prefix'] + ".txt"
    line_bak = line + ".YZT_" + dictSession['prefix'] + ".bak"
    if os.path.isfile(line) and os.path.isfile(line_new):
        if dictSystem['settings']['handler']['backup'] == True:
            os.rename(line, line_bak)
        else:
            os.remove(line)
        os.rename(line_new, line)
        
    
if globle_num2str_Version == '2':
    typein = raw_input("Press Enter to exit\n");
elif globle_num2str_Version == '3':
    typein = input("Press Enter to exit\n");
    typein=str(typein);