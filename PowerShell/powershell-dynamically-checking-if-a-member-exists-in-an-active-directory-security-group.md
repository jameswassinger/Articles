# PowerShell: Dynamically checking if a member exists in an Active Directory Security Group

There may be a time you are provided a list of usernames and asked to double-check that the list belongs to an Active Directory Security Group (AD SG).

You could manually check the list one-by-one against the Security Group's member tab, but what if your list is 50+ names long? That's really time-consuming if you manually check the list one-by-one.

Let's save some time and check the list with a PowerShell script. This PowerShell script will check the security group against the list and let you know if the username already exists in the group.

If the user does not exist in the security group. The PowerShell script will add the username to the Security group for you.

## The Script

```powershell
$groupName = "InsertGroupName"
$userList = Get-Content -Path "PathToTextFile"
ForEach($user in $Users) {
    Write-Host $user :: Already in the $groupName Security Group.
} Else {
    Add-ADGroupMember -Identity $groupName -Members $user
}
```

## Explanation of Script

- We are declaring a variable of $groupName and initializing the variable to a name of a valid Active Directory Security group name.
- We are declaring a variable of $userList and initializing the variable with the names provided within the list of names.
- Finally, we are starting the heart of the script, using a foreach loop we iterate through the provided user list. The script will output if the user is already a member of the security group and if the user is not apart of the security group the script will add the member using the Add-ADGroupMember cmdlet.
