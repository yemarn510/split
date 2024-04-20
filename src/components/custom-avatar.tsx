import { Person } from "@/models/person.models";
import { Avatar } from "antd";


export default function RoundedAvatar(params: { person: Person }): JSX.Element {
  return <div className="flex flex-col items-center gap-1 md:hover:opacity-50 cursor-pointer">
    <div className="p-1 w-fit h-fit bg-third rounded-full">
      <Avatar src={params.person.profile} className='w-8 h-8 ' />
    </div>
    <small className="text-center">{ params.person.name || '-' }</small>
  </div>
}