import { LightningElement, api, wire, track } from 'lwc';
import getUsers from '@salesforce/apex/ProjectController.getUsers';
import updateProjectOwners from '@salesforce/apex/ProjectController.updateProjectOwners';

/**
 * @description This component is used to display the selected projects and update the owner of the selected projects
 * @export
 * @class LwcSelectedProjectList
 * @extends {LightningElement}
 */
export default class LwcSelectedProjectList extends LightningElement {
    @api projects = [];
    @track selectedUserId;
    @track userOptions = [];
    @track filteredUsers = [];
    @track sendEmail = false;
    @track showDropdown = false;
    @track message = '';
    searchKey = '';
    
    /**
     * @description Getter for projectIds
     * @readonly
     * @memberof LwcSelectedProjectList
     */
    get projectIds() {
        try {
            return this.projects;
        } catch (error) {
            console.error('Error parsing projects:', error);
            this.showMessage('Error parsing projects');
            return [];
        }
    }
    
    /**
     * @description Wire method to fetch the list of users  
     * @param {*} { error, data }
     * @memberof LwcSelectedProjectList
     */
    @wire(getUsers)
    wiredUsers({ error, data }) {
        if (data) {
            this.userOptions = data.map(user => ({
                label: user.Name,
                value: user.Id
            }));
            this.filteredUsers = [...this.userOptions];
        } else if (error) {
            this.showMessage('Error fetching users');
            console.error('Error fetching users:', error);
        }
    }
    /**
     * @description Method to handle the search input event
     * @param {*} event
     * @memberof LwcSelectedProjectList
     */
    handleSearchInput(event) {
        this.searchKey = event.target.value.toLowerCase();
        if (this.searchKey) {
            this.showDropdown = true;
            this.filteredUsers = this.userOptions.filter(user => 
                user.label.toLowerCase().includes(this.searchKey)
            );
        } else {
            this.showDropdown = false;
        }
    }
    
    /**
     * @description Method to handle the focus event on the search input field
     * @memberof LwcSelectedProjectList
     */
    handleFocus() {
        this.showDropdown = true;
    }
    /**
     * @description Method to handle the blur event on the search input field
     * @param {*} event
     * @memberof LwcSelectedProjectList
     */
    handleUserSelect(event) {
        this.selectedUserId = event.target.dataset.id;
        const selectedUser = this.userOptions.find(user => user.value === this.selectedUserId);
        this.searchKey = selectedUser ? selectedUser.label : '';
        this.showDropdown = false;
    }
    
    /**
     * @description Method to handle the email change event on the checkbox field
     * @param {*} event
     * @memberof LwcSelectedProjectList
     */
    handleEmailChange(event) {
        this.sendEmail = event.target.checked;
    }
    
    /**
     * @description Method to handle the submit event on the form
     * @return {*} 
     * @memberof LwcSelectedProjectList
     */
    async handleSubmit() {
        if (!this.selectedUserId) {
            this.showMessage('Please select a new owner');
            return;
        }

        const projectIds = this.projectIds;
        if (projectIds.length === 0) {
            this.showMessage('No projects selected');
            return;
        }

        try {
            console.log('Updating project owners:', projectIds, 'New Owner:', this.selectedUserId);
            await updateProjectOwners({
                projectIds: projectIds,
                newOwnerId: this.selectedUserId,
                sendEmail: this.sendEmail
            });
            history.back();
        } catch (error) {
            console.error('Error updating project owners:', error);
            this.showMessage('Error updating project owners');
        }
    }

    /**
     * @description Method to close the modal and navigate back to the previous page
     * @memberof LwcSelectedProjectList
     */
    closeModal() {
        history.back();
    }
    
    /**
     * @description Method to show the message on the UI and hide it after 5 seconds
     * @param {*} msg
     * @memberof LwcSelectedProjectList
     */
    showMessage(msg) {
        this.message = msg;
        setTimeout(() => {
            this.message = '';
        }, 5000);
    }
    
    /**
     * @description Lifecycle method to log the projects that are sent to the LWC component
     * @memberof LwcSelectedProjectList
     */
    connectedCallback() {
        console.log('Projects:', this.projects);
        if(this.projects.length === 0) {
            this.showMessage('No projects selected');
            setTimeout(() => {
                this.closeModal();
            }, 5000);
            
            
        }
    }
}
