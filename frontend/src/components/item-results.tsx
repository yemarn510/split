import { Item } from "@/models/item.models";


export default function ItemResults(params: { items: Item[] }): JSX.Element {

  return <ul>
    {
      params?.items.map((eachItem, itemIndex) => {
        return <li key={`result-item-${itemIndex}`}
                  className='flex flex-row justify-between mb-1'>
          <div className='w-1/2'>
          { eachItem.paidBy?.name } ( { eachItem.name } )
          </div>
          <div className='w-1/2 flex flex-row justify-end'>
          {
            eachItem.isPercentage 
              ? <span>{ eachItem.percent } %</span>
              : <span>
              { eachItem.price } / { eachItem.sharedNumber } -
              </span>
          }

          <span className='min-w-[70px] text-right font-bold'>
            { eachItem.isPercentage 
              ? eachItem.price.toFixed(2)
              : (eachItem.price/eachItem.sharedNumber).toFixed(2)
            }
          </span>
          </div>
        </li>
      })
    }
  </ul>
}