import Axios, * as axios from 'axios';
import store from '@/store';

export const client = Axios.create({
    headers: {'Authorization': getAuthHeader()},
    validateStatus: ((status) => true)
})

function getAuthHeader(): string | null {
    if (store.state.srstate.token == null) return "";
    return "Bearer " + store.state.srstate.token;
}