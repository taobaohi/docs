using (var client = new SshClient("ip", "root", "pwd"))
{
    client.Connect();
    var cmd = client.RunCommand($"docker system prune -af;docker login --username=cuichong@century21 --password=docker2019 registry.cn-hangzhou.aliyuncs.com;docker run -e AREACODE_ENVIRONMENT='{areaCode}' -e DATE_ENVIRONMENT='{date}' -e DATETYPE_ENVIRONMENT='{dateType}' {APP_ENVIRONMENT} -v /data/ke_image:/app/beiFiles -d registry.cn-hangzhou.aliyuncs.com/sis6/hermitcrab:job");
    var cmdstr = @"cat ./kubejob/job-temp.yaml | sed 's/\${AREACODE}/" + areaCode + "/' | sed 's/\\${DATETYPE}/"+ dateType + "/' | sed 's/\\${DATE}/"+ date + "/' > "+ pathYmal + ";";
    cmdstr += $"kubectl delete -f {pathYmal};";
    cmdstr += $"kubectl apply -f {pathYmal};";
    client.Connect();
    var cmd = client.RunCommand(cmdstr);
    client.Disconnect();
    return cmd.ExitStatus == 0 ? "" : cmd.Error;
}