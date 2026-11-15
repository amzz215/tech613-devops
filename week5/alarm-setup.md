## Alarm Setup 

1. On a separate tab to the monitoring dashboard I open CloudWatch on the navigation search bar then click on alarms on the side navigation bar 
2. I select metric and then choose **EC2 -> Per-Instance ID** 
3. I find the app instance's ID and select that
4. Then I select its **CPUUtilization metric**
5. I click Select metric
6. For the configuration of the CPU condition I use:
   - | Setting | Value |
|---|---|
| Statistic | **Average** |
| Period | **1 minute** |
| Threshold type | **Static** |
| Whenever CPUUtilization is | **Greater** |
| Threshold value | **50** |
7. This requires two consecutive one-minute averages above 50%. I click Next.
8. Within alarm, I choose select an existing SNS topic and confirm the name, tech613-ameen-cpu-alerts. 
9. Otherwise, I choose Create new topic and then name the topic using the tech613 naming convention
10. The protool selected should be email and the endpoint should be the specific email where the alert is sent to, in this case abaruwa@company.com
11. I create Topic and then click next 
12. Now I name the alarm and give it an appropriate description 
13. I ensure **Actions are enabled** 


### Test and capture evidence

I install the stress package:

`sudo apt-get install stress -y`

I generate CPU load for four minutes, after which it stops automatically:

`stress --cpu "$(nproc)" --timeout 240s`

Alert: 
- ![Screenshot](<../images/Screenshot 2026-10-28 173121.png>)
- ![Screenshot](<../images/Screenshot 2026-10-28 173130.png>)