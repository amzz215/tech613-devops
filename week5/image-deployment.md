## Image Creation 

What is an Image?

An image is a snapshot of an applications current files and configurations.

### Image Creation- Setup 

1. Use the commad `PM2 kill` to stop the application before stopping the instance/image 
2. Once instance/image is stopped. Select **actions** and then select **image and templates** and finally click **create image** 
    - ![pic](images/Screenshot 2026-10-26 154226.png)
3. Name image and describe image appropriately so it's easily identifiable.
    - ![pic](images/Screenshot 2026-10-26 154226.png)
4. Once Image has been named appropriately, create the image 
5. Once image status is complete, select instances on the side tab 
6. Then create an instance as normal but this time instead of selecting Ubuntu for my operating system. Now I actually select **My AMIs** 
   - ![pic](images/Screenshot 2026-10-26 154657.png)
7. Once instance has been created we can simply just copy the public IP address into a web browser and remove `s` from `HTTPS` and the app should be working 
8. The more manual way would be to connect into the VM using the Public DNS provided and then replacing root@ with ubuntu@ on git bash 
   - ![pic](images/Screenshot 2026-10-26 155854.png)
9.  Once logged into ubuntu, I `cd` into app and from app run this command `sudo env PATH="$PATH" pm2 startup systemd -u root --hp /root` then this `pm2 restart tictactoe || pm2 start npm --name tictactoe -- start`
    - This command is option as the npm is already started when the instance is initiated as image is created on top of the instance. 