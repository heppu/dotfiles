Invoke-WebRequest -Uri "http://kvm.heppu.io/rpc" -ContentType "application/json" -Method POST -Body '{"id":0,"method":"Switch.Set","params":{"id":0,"on":true}}'
