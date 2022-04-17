import os
import sys
import re
import shutil
import requests
 
git_ip = []
hosts_datas=[]

def getip(website:str):
    # 获取IP地址
    request = requests.get('https://ipaddress.com/website/'+website)
    if request.status_code == 200:
        ips=re.findall(r"<strong>(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}?)</strong>", request.text)
        for ip_item in ips:
            git_ip.append(ip_item+' '+website)
 
getip('github.com')
getip('gist.github.com')
getip('github.global.ssl.fastly.net')
getip('uploads.github.com')
getip('objects-origin.githubusercontent.com')
getip('objects-origin.githubusercontent.com')
getip('githubstatus.com')
getip('collector.github.com')
getip('raw.githubusercontent.com')
getip('api.github.com')
getip('assets-cdn.github.com')
getip('gist.githubusercontent.com')
getip('cloud.githubusercontent.com')
getip('camo.githubusercontent.com')
getip('github.githubassets.com')
getip('identicons.github.com')

hosts_dir=r'/etc/'
orign_hosts=os.path.join(hosts_dir,'hosts')
temp_hosts=os.path.join(sys.path[0],'hosts')
 
# 读取原来hosts内容
with open(orign_hosts,'r',encoding='utf-8') as orign_file:
    datas = orign_file.readlines()
 
# 复制hosts内容
hosts_datas=datas.copy()
 
# 删除原来github相关内容
for data in datas:
    if 'github' in data or data=='\n':
        hosts_datas.remove(data)
 
# 合并生成新hosts内容
hosts_datas.extend(git_ip)
 
# 生成临时hosts文件
with open(temp_hosts,'w') as temp_file:
    for host in hosts_datas:
        temp_file.writelines(host+'\n')
 
try:
    # 备份 覆盖 系统hosts文件
    shutil.move(orign_hosts,orign_hosts+'.bak')
    shutil.copy(temp_hosts,orign_hosts)
    print("hosts udpate done!")
except:
    print("pls run by root!")
 